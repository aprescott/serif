module Serif
  module Placeholder
    def self.substitute(input, substitutions)
      output = input

      substitutions.each do |placeholder_name, value|
        output = output.gsub(Regexp.quote(":" + placeholder_name), value)
      end

      output
    end
  end
end
