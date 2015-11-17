RSpec.configure do |config|
  config.before(turnip: true) do
    example = Turnip::RSpec.fetch_current_example(self)
    feature_file = example.metadata[:file_path]

    turnip_file_path = Pathname.new(feature_file).realpath

    # sadly Dir.pwd might have changed because of aprescott/serif#71, so we need
    # to find the equivalent of Rails.root
    root_app_folder = Pathname.new(Dir.pwd)
    root_app_folder = root_app_folder.parent until root_app_folder.children(false).map(&:to_s).include?("serif.gemspec")

    root_acceptance_folder = root_app_folder.join("spec", "acceptance")

    default_steps_file = root_acceptance_folder + turnip_file_path.relative_path_from(root_acceptance_folder).to_s.gsub(/^features/, "steps").gsub(/\.feature$/, "_steps.rb")
    default_steps_module = [turnip_file_path.basename.to_s.sub(".feature", "").split("_").collect(&:capitalize), "Steps"].join

    require default_steps_file.to_s
    extend Module.const_get(default_steps_module)
  end
end
