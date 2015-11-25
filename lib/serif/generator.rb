module Serif
  class Generator
    attr_reader :site

    def initialize(site)
      @site = site
    end

    def default_layout
      Liquid::Template.parse(File.read(site.source_path("_layouts/default.html")))
    end

    def generate!
      Dir.chdir(site.source_directory) do
        FileUtils.rm_rf("tmp/_site")
        FileUtils.mkdir_p("tmp/_site")

        if site.conflicts
          raise PostConflictError, "Generating would cause a conflict."
        end

        puts "Auto-publishing drafts..."
        preprocess_autopublish_drafts
        puts "Auto-updating posts..."
        preprocess_autoupdate_posts

        puts "Processing general files..."
        process_general_files
        puts "Processing published posts..."
        process_posts

        puts
        puts "Draft previews created:"
        puts generate_draft_previews.join("\n")

        if site.config.archive_enabled?
          generate_archives(default_layout)
        end

        update_site_path
      end
    end

    private

    def preprocess_autoupdate_posts
      site.posts.each do |p|
        if p.autoupdate?
          p.update!
        end
      end
    end

    def generate_draft_previews
      site.drafts.map do |draft|
        preview_path = draft_preview_path(draft)

        live_preview_file = site.tmp_path(preview_path)
        FileUtils.mkdir_p(File.dirname(live_preview_file))

        File.open(live_preview_file + ".html", "w") do |f|
          f.puts draft.render(site)
        end

        preview_path
      end
    end

    def draft_preview_path(draft)
      private_draft_pattern = site.site_path("drafts/#{draft.slug}/*")
      existing_file = Dir[private_draft_pattern].first

      file = existing_file ? File.basename(existing_file, ".html") : SecureRandom.hex(30)

      "drafts/#{draft.slug}/#{file}"
    end

    def preprocess_autopublish_drafts
      site.drafts.each do |d|
        if d.autopublish?
          d.publish!
        end
      end
    end

    def process_general_files
      files = Dir["**/*"].select { |f| f !~ /\A_/ && File.file?(f) }

      files.each do |path|
        dirname = File.dirname(path)
        filename = File.basename(path)

        FileUtils.mkdir_p(site.tmp_path(dirname))

        if bypass?(filename)
          FileUtils.cp(path, site.tmp_path(path))
          next
        end

        page = Serif::Page.new(site, path)

        File.open(site.tmp_path(path), "w") do |f|
          f.puts page.render
        end
      end
    end

    def process_posts
      [nil, *site.posts, nil].each_cons(3) do |next_post, post, prev_post|
        FileUtils.mkdir_p(site.tmp_path(File.dirname(post.url)))

        File.open(site.tmp_path(post.url + ".html"), "w") do |f|
          f.puts post.render(site, prev_post: prev_post, next_post: next_post)
        end
      end
    end

    def generate_archives(layout)
      template = Liquid::Template.parse(File.read(site.source_path("_templates/archive_page.html")))

      months = site.posts.group_by { |post| Date.new(post.created.year, post.created.month) }

      months.each do |month, posts|
        archive_path = site.tmp_path(site.archive_url_for_date(month))

        FileUtils.mkdir_p(File.dirname(archive_path))

        File.open(File.join(archive_path + ".html"), "w") do |f|
          f.puts layout.render!(
            "archive_page" => true,
            "month" => month,
            "site" => site,
            "content" => template.render!("archive_page" => true, "site" => site, "month" => month, "posts" => posts)
          )
        end
      end
    end

    def update_site_path
      FileUtils.rm_rf(site.source_path("_site")) &&
        FileUtils.mv(site.source_path("tmp/_site"), site.source_directory) &&
        FileUtils.rm_rf(site.source_path("tmp"))
    end

    def bypass?(filename)
      !%w[.html .xml].include?(File.extname(filename))
    end
  end
end
