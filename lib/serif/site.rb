require "liquid"
require "time"
require "fileutils"
require "securerandom"

module Serif
  class Site
    attr_reader :source_directory

    def initialize(directory)
      raise ArgumentError, "a source directory must be given" unless directory

      @source_directory = directory
    end

    def pages
      Page.all(self)
    end

    def posts
      Post.all(self).sort_by { |entry| entry.created }.reverse
    end

    def drafts
      Draft.all(self)
    end

    def config
      @config ||= Serif::Config.new(source_path("_config.yml"))
    end

    def source_path(*path)
      File.join(source_directory, *path)
    end

    def site_path(path)
      source_path("_site", path)
    end

    def tmp_path(path)
      File.join("tmp", File.join("_site", path))
    end

    def latest_update_time
      most_recent = posts.max_by { |p| p.updated }
      most_recent ? most_recent.updated : Time.now
    end

    def archive_url_for_date(date)
      parts = {
        "year" => date.year.to_s,
        "month" => date.month.to_s.rjust(2, "0")
      }

      Serif::Placeholder.substitute(config.archive_url_format, parts)
    end

    def archives
      h = {
        "posts" => posts,
        "years" => posts.group_by { |p| Date.new(p.created.year) }.map do |year_date, year_posts|
          year_posts = year_posts.sort_by(&:created).reverse

          {
            "date" => year_date,
            "posts" => year_posts,
            "months" => year_posts.group_by { |p| Date.new(p.created.year, p.created.month) }.to_a.map do |month_date, month_posts|
              month_posts = month_posts.sort_by(&:created).reverse

              {
                "date" => month_date,
                "posts" => month_posts,
                "archive_url" => archive_url_for_date(month_date)
              }
            end
          }
        end
      }

      h["years"].sort_by! { |el| el["date"] }
      h["years"].reverse!

      h
    end

    def conflicts
      conflicts = (drafts + posts).group_by(&:url)
      conflicts.select! { |url, entries| entries.length > 1 }

      if conflicts.empty?
        nil
      else
        conflicts
      end
    end

    def to_liquid
      {
        "posts" => posts,
        "latest_update_time" => latest_update_time,
        "archive" => archives,
        # exists to allow the file_digest tag to work
        "__directory" => source_directory
      }
    end

    def generate
      Serif::Generator.new(self).generate!
    end
  end
end
