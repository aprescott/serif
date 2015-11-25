RSpec.describe "Liquid filters and tags" do
  {
    markdown: [
      %Q~{{ "*some markdown*" | markdown }}~, "<p><em>some markdown</em></p>"
    ],
    smarty: [
      %Q~{{ "testing's for a " | append: '"' | append: "heading's" | append: '"' | append: " `with code` in it..." | smarty }}~, "testing&#8217;s for a &#8220;heading&#8217;s&#8221; `with code` in it&#8230;"
    ],
    strip: [
      %Q~{{ " testing " | strip }}~, "testing"
    ],
    xmlschema: [
      %Q~{{ site.latest_update_time | xmlschema }}~, "2400-01-01T00:00:00Z"
    ],
    encode_uri_component: [
      %Q~{{ "x&y" | encode_uri_component }}~, "x%26y"
    ],
    file_digest: [
      %Q~{% file_digest test-stylesheet.css %}~, "f8390232f0c354a871f9ba0ed306163c"
    ]
  }.each do |tag, (input, expected_output)|
    describe "| #{tag}" do
      it "is supported in non-post pages, in the layout and the file" do
        with_file_contents(testing_dir("_layouts/test--with-#{tag}.html"), "<div id=layout>\n\n#{input}\n\n</div>\n\n{{ content }}") do
          with_file_contents(testing_dir("test--some-file-with-#{tag}.html"), "layout: test--with-#{tag}\n\n<div id=file>\n\n#{input}</div>") do
            generate_site

            expect(File.read(testing_dir("_site/test--some-file-with-#{tag}.html")).strip).to include("<div id=file>\n\n#{expected_output}")
            expect(File.read(testing_dir("_site/test--some-file-with-#{tag}.html")).strip).to include("<div id=layout>\n\n#{expected_output}")
          end
        end
      end
    end
  end

  describe "file_digest" do
    before do
      generate_site
    end

    it "is empty in non-prod environments" do
      expect(File.read(testing_dir("_site/test--page-with-a-filedigest-filter.html")).strip).to eq("f8390232f0c354a871f9ba0ed306163c\nf8390232f0c354a871f9ba0ed306163c\n.f8390232f0c354a871f9ba0ed306163c")

      generate_site(env: nil)
      expect(File.read(testing_dir("_site/test--page-with-a-filedigest-filter.html")).strip).to eq("")

      generate_site(env: "development") # really: just not-production
      expect(File.read(testing_dir("_site/test--page-with-a-filedigest-filter.html")).strip).to eq("")
    end
  end
end
