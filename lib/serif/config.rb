require "yaml"

module Serif
  class Config
    def initialize(config_file)
      @config_file = config_file
    end

    def permalink
      yaml_config["permalink"] || "/:title"
    end

    def archive_enabled?
      archive_config["enabled"]
    end

    def archive_url_format
      archive_config["url_format"] || "/archive/:year/:month"
    end

    private

    def yaml_config
      @yaml_config ||= YAML.load_file(@config_file)
    end

    def archive_config
      yaml_config["archive"] || {}
    end
  end
end
