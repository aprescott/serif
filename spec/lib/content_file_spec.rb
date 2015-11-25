RSpec.describe Serif::ContentFile do
  let(:site) { double }
  let(:file_contents) { "x: 1\n\nsome content" }
  let(:file_path) { "some-path" }

  include_examples "a content file" do
    let(:expected_liquid_hash) do
      {
        "content" => "content value",
        "slug" => "slug value",
        "url" => "url value",
        "draft" => "draft? value",
        "published" => "published? value"
      }
    end
  end
end
