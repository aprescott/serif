require "sinatra/base"
require "fileutils"

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
      drafts = site.drafts.sort_by { |p| p.slug }.reverse

      liquid :index, locals: { posts: posts, drafts: drafts }
    end

    get "/admin/edit/?" do
      redirect to("/admin"), 301
    end

    get "/admin/new/draft" do
      content = Draft.new(site)
      autofocus = "slug"
      liquid :new_draft, locals: { post: content, autofocus: autofocus }
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

        liquid :new_draft, locals: { error_message: error_message, post: content, autofocus: autofocus }
      else
        if Draft.exist?(site, params[:slug])
          liquid :new_draft, locals: { error_message: error_message, post: content, autofocus: autofocus }
        else
          content.save(params[:markdown])
          site.generate
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
          Draft.rename(params[:original_slug], params[:slug])

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

        liquid :edit_draft, locals: { error_message: error_message, post: content, private_url: site.private_url(content) }
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
      content = Post.from_slug(site, params[:original_slug])

      params[:markdown] = params[:markdown].strip
      params[:title] = params[:title].strip

      content.title = params[:title]

      if params[:markdown].empty? || params[:title].empty?
        error_message = "Content must not be blank." if params[:markdown].empty?
        error_message = "Title must not be blank." if params[:title].empty?

        liquid :edit_post, locals: { error_message: error_message, post: content }
      else
        content.save(params[:markdown])
        site.generate

        redirect to("/admin")
      end
    end

    get "/admin/edit/:type/:slug" do
      redirect to("/admin") unless params[:slug]

      if params[:type] == "posts"
        content = site.posts.find { |p| p.slug == params[:slug] }
        liquid :edit_post, locals: { post: content, autofocus: "markdown" }
      elsif params[:type] == "drafts"
        content = Draft.from_slug(site, params[:slug])
        liquid :edit_draft, locals: { post: content, autofocus: "markdown", private_url: site.private_url(content) }
      else
        response.status = 404
        return "Nope"
      end
    end

    post "/admin/delete/?" do
      content = Draft.from_slug(site, params[:original_slug])
      content.delete!

      redirect to("/admin")
    end

    post "/admin/convert-markdown/?" do
      content = params["content"]

      if request.xhr?
        Redcarpet::Markdown.new(Serif::MarkupRenderer, fenced_code_blocks: true).render(content).strip
      end
    end

    post "/admin/attachment" do
      attachment = params["attachment"]
      filename = attachment["name"]
      file = attachment["file"]
      tempfile = file[:tempfile]
      uid = attachment["uid"]

      relative_path =  "/images/#{uid}#{File.extname(filename)}"

      FileUtils.mkdir_p(File.join(site.directory, "images"))

      # move to the source directory
      FileUtils.mv(tempfile.path, File.join(site.directory, relative_path))

      # copy to production to avoid the need to generate right now
      FileUtils.copy(File.join(site.directory, relative_path), site.site_path(relative_path))

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