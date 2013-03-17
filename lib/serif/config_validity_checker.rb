module Serif
module Config::ValidityChecker
  # Takes a Serif::Config instance. For any configuration problems,
  # prints to stdout and returns false. Returns true if everything
  # is fine.
  #
  # Mostly, all config settings have fallback values, but for those
  # that are necessary, this will check they exist.
  def self.valid?(config)
    valid = true

    errors = []

    if config.feed["enabled"]
       errors << "Feed generation enabled, but base_url missing." unless config.base_url
       errors << "Feed generation requires a permanent unique ID" unless config.feed["permanent_unique_id"]
       errors << "Feed generation needs a permanent unique ID (found #{config.feed["permanent_unique_id"]}) starting with <YEAR>:" if config.feed["permanent_unique_id"] && config.feed["permanent_unique_id"] !~ /\A\d{4}:\S+\z/
       errors << "Feed generation requires an author name" unless config.feed["author_name"]
       errors << "Feed generation requires a domain" unless config.feed["domain"]
       errors << "Feed generation requires a title" unless config.feed["title"]
    end

    valid = errors.empty?

    errors.each do |e|
      puts e
    end

    valid
  end
end
end
