require "sinatra/base"
require "fileutils"
require "nokogiri"
require "reverse_markdown"

module Serif
class AdminServer
  class AdminApp < Sinatra::Base
    Tilt.register :html, Tilt[:liquid]


    set :root, Dir.pwd
    set :public_folder, settings.root + (ENV["ENV"] == "production" ? "/_site" : "")
    set :views, File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "statics", "templates", "admin"))

    site = Serif::Site.new(settings.root)

    use(Rack::Auth::Basic, "Login credentials") do |username, password|
      [username, password] == [site.config.admin_username, site.config.admin_password]
    end

    before do
      @conflicts = site.conflicts
    end

    # multiple public folders??
    get "/admin/js/:file" do |file|
      assets_dir = File.join(File.dirname(__FILE__), "..", "..", "statics", "assets", "js")

      [200, { "Content-Type" => "text/javascript" }, File.read(File.join(assets_dir, file))]
    end

    get "/" do
      redirect to("/admin")
    end

    get "/admin/?" do
      posts = site.posts.sort_by { |p| p.created }.reverse
      drafts = site.drafts.sort_by { |p| File.mtime(p.path) }.reverse

      liquid :index, locals: { conflicts: @conflicts, posts: posts, drafts: drafts }
    end

    get "/admin/edit/?" do
      redirect to("/admin"), 301
    end

    get "/admin/bookmarks" do
      liquid :bookmarks, locals: { conflicts: @conflicts }
    end

    get "/admin/quick-draft" do
      url = params[:url]
      html_content = params[:content].strip

      title = params[:title]

      # delete anything nonprintable
      title = title.gsub(/[^\x20-\x7E]/, "")

      # sanitise the HTML title into something we can use as a temporary slug
      slug = title.split(" ").first(5).join(" ").gsub(/[^\w-]/, "-").gsub(/--+/, '-').gsub(/^-|-$/, '')
      slug.downcase!

      if html_content.empty?
        markdown = "[#{title}](#{url.gsub(")", "\\)")})"
      else
        # parse the document fragment and remove any empty nodes.
        document = Nokogiri::HTML::DocumentFragment.parse(html_content)
        document.traverse { |p| p.remove if p.text && p.text.strip.empty? }
        html_content = document.to_html

        html_content = "<blockquote>#{html_content}</blockquote>"
        markdown = ReverseMarkdown.parse(html_content, github_style_code_blocks: true)

        # markdown URLs need to have any )s escaped
        markdown = "[#{title}](#{url.gsub(")", "\\)")}):\n\n#{markdown}"
      end

      draft = Draft.new(site)
      draft.title = title
      draft.slug = slug

      # if the draft itself has no conflict, save it,
      # otherwise show the new draft page with an error.
      #
      # if, after saving the draft because of no conflict,
      # there is actually an overall site conflict, then
      # keep on trucking so it doesn't interrupt the user.
      if site.conflicts(draft)
        liquid :new_draft, locals: { conflicts: @conflicts, images_path: site.config.image_upload_path.gsub(/"/, '\"'), post: draft, error_message: "There is a conflict on this draft." }
      else
        draft.save(markdown)

        begin
          site.generate
        rescue PostConflictError => e
          puts "Site has conflicts, skipping generation for now."
        end

        if params[:edit] == "1"
          redirect to("/admin/edit/drafts/#{slug}")
        else
          redirect to(url)
        end
      end
    end

    get "/admin/new/draft" do
      content = Draft.new(site)
      autofocus = "slug"
      liquid :new_draft, locals: { conflicts: @conflicts, images_path: site.config.image_upload_path.gsub(/"/, '\"'), post: content, autofocus: autofocus }
    end

    post "/admin/new/draft" do
      content = Draft.new(site)
      content.slug = params[:slug].strip
      content.title = params[:title].strip

      if params[:markdown].strip.empty? || params[:title].empty? || params[:slug].empty?
        [:title, :slug, :markdown].each do |p|
          params[p] = nil if params[p] && params[p].empty?
        end

        error_message = "There must be a URL, a title, and content to save."

        autofocus = "markdown" unless params[:markdown]
        autofocus = "title" unless params[:title]
        autofocus = "slug" unless params[:slug]

        liquid :new_draft, locals: { draft_content: params[:markdown], conflicts: @conflicts, images_path: site.config.image_upload_path.gsub(/"/, '\"'), error_message: error_message, post: content, autofocus: autofocus }
      else
        if Draft.exist?(site, params[:slug])
          error_message = "Draft already eixsts with the given slug #{params[:slug]}."
          liquid :new_draft, locals: { draft_content: params[:markdown], conflicts: @conflicts, images_path: site.config.image_upload_path.gsub(/"/, '\"'), error_message: error_message, post: content, autofocus: autofocus }
        else
          content.save(params[:markdown])
          begin
            site.generate
          rescue PostConflictError => e
            puts "Cannot generate. Skipping for now."
          end
          redirect to("/admin")
        end
      end
    end

    post "/admin/edit/drafts" do
      content = Draft.from_slug(site, params[:original_slug])

      params[:markdown] = params[:markdown].strip

      # check if the slug has been edited, i.e., if we're renaming.
      if !params[:slug].empty? && params[:original_slug] && params[:original_slug] != params[:slug]
        if Draft.exist?(site, params[:slug])
          conflicting_name = true

          # we need to re-edit, so reload but use the original slug name
          # not the new one that was attempted to be saved.
          content = Draft.from_slug(site, params[:original_slug])
        else
          Draft.rename(site, params[:original_slug], params[:slug])

          # re-load after the rename
          content = Draft.from_slug(site, params[:slug])
        end
      end

      # make sure the title is whatever was just submitted
      content.title = params[:title]

      # any errors
      if conflicting_name || params[:markdown].empty? || params[:slug].empty?
        if conflicting_name
          error_message = "This name is already being used for a draft."
        elsif params[:markdown].empty?
          error_message = "Content must not be blank."
        elsif params[:slug].empty?
          error_message = "You must pick a URL to use"
        end

        liquid :edit_draft, locals: { draft_content: params[:markdown], conflicts: @conflicts, images_path: site.config.image_upload_path.gsub(/"/, '\"'), error_message: error_message, post: content, private_url: site.private_url(content) }
      elsif (conflicts = site.conflicts)
        error_message = "The site has a conflict and cannot be generated."
        liquid :edit_draft, locals: { draft_content: params[:markdown], conflicts: @conflicts, images_path: site.config.image_upload_path.gsub(/"/, '\"'), error_message: error_message, post: content, private_url: site.private_url(content) }
      else
        content.save(params[:markdown])

        # TODO: move the entire notion of generating a site out into
        #       a directory-change-level event.
        if params[:publish] == "yes"
          content.publish!
        end

        site.generate

        redirect to("/admin")
      end
    end

    post "/admin/edit/posts" do
      content = Post.from_basename(site, params[:original_basename])

      params[:markdown] = params[:markdown].strip
      params[:title] = params[:title].strip

      content.title = params[:title]

      if params[:markdown].empty? || params[:title].empty?
        error_message = "Content must not be blank." if params[:markdown].empty?
        error_message = "Title must not be blank." if params[:title].empty?

        liquid :edit_post, locals: { conflicts: @conflicts, images_path: site.config.image_upload_path.gsub(/"/, '\"'), error_message: error_message, post: content }
      elsif (conflicts = site.conflicts)
        error_message = "The site has a conflict and cannot be generated."
        liquid :edit_post, locals: { conflicts: @conflicts, images_path: site.config.image_upload_path.gsub(/"/, '\"'), error_message: error_message, post: content }
      else
        content.save(params[:markdown])
        site.generate

        redirect to("/admin")
      end
    end

    get "/admin/edit/posts/:basename" do
      redirect to("/admin") unless params[:basename]

      content = Post.from_basename(site, params[:basename])
      liquid :edit_post, locals: { conflicts: @conflicts, images_path: site.config.image_upload_path.gsub(/"/, '\"'), post: content, autofocus: "markdown" }
    end

    get "/admin/edit/drafts/:slug" do
      redirect to("/admin") unless params[:slug]

      content = Draft.from_slug(site, params[:slug])
      liquid :edit_draft, locals: { conflicts: @conflicts, images_path: site.config.image_upload_path.gsub(/"/, '\"'), post: content, autofocus: "markdown", private_url: site.private_url(content) }
    end

    post "/admin/delete/?" do
      content = Draft.from_slug(site, params[:original_slug])
      content.delete!

      redirect to("/admin")
    end

    post "/admin/convert-markdown/?" do
      content = params["content"]

      if request.xhr?
        Redcarpet::Markdown.new(Serif::MarkupRenderer, fenced_code_blocks: true, tables: true).render(content).strip
      end
    end

    post "/admin/attachment" do
      attachment = params["attachment"]
      filename = attachment["final_name"]
      file = attachment["file"]
      uid = attachment["uid"]

      tempfile = file[:tempfile]

      FileUtils.mkdir_p(File.join(site.directory, File.dirname(filename)))
      FileUtils.mkdir_p(File.dirname(site.site_path(filename)))

      source_file = File.join(site.directory, filename)
      deployed_file = site.site_path(filename)

      # move to the source directory
      FileUtils.mv(tempfile.path, source_file)

      # copy to production to avoid the need to generate right now
      FileUtils.copy(source_file, deployed_file)

      # no executable permissions, and whatever the umask is
      perms = 0777 & ~0111 & ~File.umask
      File.chmod(perms, source_file, deployed_file)

      "File uploaded"
    end
  end

  def initialize(source_directory)
    @source_directory = File.expand_path(source_directory)
  end

  def start
    FileUtils.cd @source_directory
    app = Sinatra.new(AdminApp)
    app.run!
  end
end
end