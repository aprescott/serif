RSpec.describe "Pages" do
  it "renders Liquid markup" do
    with_file_contents(testing_dir("regular-file.html"), "some content {{ 'goes here' }}") do
      generate_site

      expect(File.read(testing_dir("_site/regular-file.html")).strip).to eq("<div id=default-layout>\n\nsome content goes here\n</div>")
    end
  end

  it "uses the default layout" do
    with_file_contents(testing_dir("regular-file.html"), "title: a title\n\nsome content") do
      generate_site

      rendered = File.read(testing_dir("_site/regular-file.html"))
      expect(rendered).to eq("<div id=default-layout>\n\nsome content\n</div>\n")
    end
  end

  it "allows a custom layout" do
    with_file_contents(testing_dir("_layouts/custom.html"), "custom layout\n\n{{ content }}") do
      with_file_contents(testing_dir("regular-file.html"), "layout: custom\n\nsome content") do
        generate_site

        rendered = File.read(testing_dir("_site/regular-file.html"))
        expect(rendered).to eq("custom layout\n\nsome content\n\n")
      end
    end
  end

  it "uses all given header values in both the layout and the template" do
    with_file_contents(testing_dir("_layouts/custom.html"), "custom layout {{ site.posts | size }} {{ page.header_a }} {{ page.header_b | upcase }} ({{ page.layout }}) {{ page.title }}\n\n{{ content }}") do
      with_file_contents(testing_dir("regular-file.html"), "layout: custom\nheader_a: header-a-val\nheader_b: header-b-val\ntitle: a title\n\nsome content {{ site.posts | size }} {{ page.header_a }} {{ page.header_b | upcase }} ({{ page.layout }}) {{ page.title }}") do
        generate_site

        rendered = File.read(testing_dir("_site/regular-file.html")).split("\n\n")
        expect(rendered).to eq([
          "custom layout 8 header-a-val #{"header-b-val".upcase} (custom) a title",
          "some content 8 header-a-val #{"header-b-val".upcase} (custom) a title"
        ])
      end
    end
  end
end
