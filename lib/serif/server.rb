require "sinatra/base"

module Serif
  class DevelopmentServer
    class DevApp < Sinatra::Base
      set :public_folder, Dir.pwd

      not_found { "Resource not found" }

      get "/" do
        File.read(File.expand_path("_site/index.html"))
      end

      # it seems Rack::Rewrite doesn't like public_folder files, so here we are
      get "*" do
        # attempt the exact name + an extension
        file = Dir[File.expand_path("_site#{params[:splat].join("/")}.*")].first

        # try index.html under the directory if it failed. useful for archive directory requests.
        file ||= Dir[File.expand_path("_site#{params[:splat].join("/")}/index.html")].first

        # make a naive assumption that there's a 404 file at 404.html
        file ||= Dir[File.expand_path("_site/404.html")].first

        file ? File.read(file) : 404
      end
    end

    attr_reader :source_directory

    def initialize(source_directory)
      raise ArgumentError, "a source directory must be given" unless source_directory

      @source_directory = source_directory
    end

    def start
      Dir.chdir(source_directory) do
        app = Sinatra.new(DevApp)
        app.run!(port: 8000)
      end
    end
  end
end
