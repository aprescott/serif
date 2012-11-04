class StandardFilterCheck
  include Liquid::StandardFilters

  def date_supports_now?
    date("now", "%Y") == Time.now.year
  end
end

if StandardFilterCheck.new.date_supports_now?
  puts "NOTICE! 'now' is supported by 'date' filter. Remove the patch"
  sleep 5 # incur a penalty
else
  module Liquid::StandardFilters
    alias_method :date_orig, :date

    def date(input, format)
      input == "now" ? date_orig(Time.now, format) : date_orig(input, format)
    end
  end
end

module Filters
  def strip(input)
    input.strip
  end

  def encode_uri_component(string)
    CGI.escape(string)
  end

  def markdown(body)
    Redcarpet::Markdown.new(Serif::MarkupRenderer, fenced_code_blocks: true).render(body).strip
  end

  def xmlschema(input)
    input.xmlschema
  end
end

Liquid::Template.register_filter(Filters)

module Serif
class Site
  def initialize(source_directory)
    @source_directory = source_directory
  end

  def directory
    @source_directory
  end

  def posts
    Post.all(self)
  end

  def drafts
    Draft.all(self)
  end

  def config
    Serif::Config.new(File.join(@source_directory, "_config.yml"))
  end

  def site_path(path)
    File.join("_site", path)
  end

  def tmp_path(path)
    File.join("tmp", site_path(path))
  end

  def latest_update_time
    most_recent = posts.max_by { |p| p.updated }
    most_recent ? most_recent.updated : Time.now
  end

  def bypass?(filename)
    !%w[.html .xml].include?(File.extname(filename))
  end

  # TODO: fix all these File.join calls
  def generate
    FileUtils.cd(@source_directory)

    FileUtils.rm_rf("tmp/_site")
    FileUtils.mkdir_p("tmp/_site")

    files = Dir["**/*"].select { |f| f !~ /\A_/ && File.file?(f) }

    layout = Liquid::Template.parse(File.read("_layouts/default.html"))
    posts = self.posts.sort_by { |entry| entry.created }.reverse

    files.each do |path|
      puts "Processing file: #{path}"

      dirname = File.dirname(path)
      filename = File.basename(path)

      FileUtils.mkdir_p(tmp_path(dirname))
      if bypass?(filename)
        FileUtils.cp(path, tmp_path(path))
      else
        File.open(tmp_path(path), "w") do |f|
          file = File.read(path)
          title = nil
          layout_option = :default

          begin
            file_with_headers = Redhead::String[File.read(path)]
            title = file_with_headers.headers[:title] && file_with_headers.headers[:title].value
            layout_option = file_with_headers.headers[:layout] && file_with_headers.headers[:layout].value

            # all good? use the headered string
            file = file_with_headers
          rescue => e
            puts "Warning! Problem trying to get headers out of #{path}"
            puts e
            # stick with what we've got!
          end

          if layout_option == "none"
            f.puts Liquid::Template.parse(file.to_s).render!("site" => { "posts" => posts, "latest_update_time" => latest_update_time })
          else
            f.puts layout.render!("page" => { "title" => [title].compact }, "content" => Liquid::Template.parse(file.to_s).render!("site" => { "posts" => posts, "latest_update_time" => latest_update_time }))
          end
        end
      end
    end

    posts.each do |post|
      puts "Processing post: #{post.path}"

      FileUtils.mkdir_p(tmp_path(File.dirname(post.url)))

      File.open(tmp_path(post.url + ".html"), "w") do |f|
        f.puts layout.render!("page" => { "title" => ["Posts", "#{post.title}"] }, "content" => Liquid::Template.parse(File.read("_templates/post.html")).render!("post" => post))
      end
    end

    if Dir.exist?("_site")
      FileUtils.mv("_site", "/tmp/_site.#{Time.now.strftime("%Y-%m-%d-%H-%M-%S")}")
    end

    FileUtils.mv("tmp/_site", ".") && FileUtils.rm_rf("tmp/_site")
    FileUtils.rmdir("tmp")
  end
end
end