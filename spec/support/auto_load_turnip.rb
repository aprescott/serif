# See https://github.com/jnicklas/turnip/pull/96
# with a tweak to group features into acceptance/features/ alongside
# acceptance/steps/

module Turnip
  module RSpec
    class << self
      def run(feature_file)
        Turnip::Builder.build(feature_file).features.each do |feature|
          describe feature.name, feature.metadata_hash do
            before do
              # This is kind of a hack, but it will make RSpec throw way nicer exceptions
              example.metadata[:file_path] = feature_file

              turnip_file_path = Pathname.new(feature_file)
              root_acceptance_folder = Pathname.new(Dir.pwd).join("spec", "acceptance")

              default_steps_file = root_acceptance_folder + turnip_file_path.relative_path_from(root_acceptance_folder).to_s.gsub(/^features/, "steps").gsub(/\.feature$/, "_steps.rb")
              default_steps_module = [turnip_file_path.basename.to_s.sub(".feature", "").split("_").collect(&:capitalize), "Steps"].join

              if File.exists?(default_steps_file)
                require default_steps_file
                if Module.const_defined?(default_steps_module)
                  extend Module.const_get(default_steps_module)
                end
              end

              feature.backgrounds.map(&:steps).flatten.each do |step|
                run_step(feature_file, step)
              end
            end
            feature.scenarios.each do |scenario|
              instance_eval <<-EOS, feature_file, scenario.line
                describe scenario.name, scenario.metadata_hash do it(scenario.steps.map(&:description).join(" -> ")) do
                    scenario.steps.each do |step|
                      run_step(feature_file, step)
                    end
                  end
                end
              EOS
            end
          end
        end
      end
    end
  end
end
