require "sinatra/base"
require "fileutils"
require "rack/rewrite"

module Serif
class DevelopmentServer
  class DevApp < Sinatra::Base
    set :public_folder, Dir.pwd

    get "/" do
      File.read(File.expand_path("_site/index.html"))
    end

    # it seems Rack::Rewrite doesn't like public_folder files, so here we are
    get "*" do
      File.read(Dir[File.expand_path("_site#{params[:splat].join("/")}.*")].first)
    end
  end

  attr_reader :source_directory

  def initialize(source_directory)
    @source_directory = source_directory
  end

  def start
    FileUtils.cd @source_directory
    app = Sinatra.new(DevApp)
    app.run!(:port => 8000)
  end
end
end