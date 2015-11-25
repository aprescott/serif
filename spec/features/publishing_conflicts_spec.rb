RSpec.describe "Site generation with publishing conflicts" do
  it "fails because of conflicts" do
    with_file_contents(testing_dir("_posts/#{Time.now.strftime("%Y-%m-%d")}-test--existing-post"), "title: Existing post\nCreated: 1960-12-31T05:06:07Z\n\nsome existing content") do
      expect(Dir[testing_dir("_posts/*")].length).to eq(9)
      expect { generate_site }.to_not raise_error

      # collision based on the default permalink config
      with_file_contents(testing_dir("_drafts/test--existing-post"), "title: A brand new post\n\nsome existing content") do
        expect { generate_site }.to raise_error(TestingSiteGenerationError, "failed to generate site")
        expect(Dir[testing_dir("_posts/*")].length).to eq(9)
      end

      # collision based on the same, but where the post would be published
      with_file_contents(testing_dir("_drafts/test--existing-post"), "title: A brand new post\npublish: now\n\nsome existing content") do
        expect { generate_site }.to raise_error(TestingSiteGenerationError, "failed to generate site")
        expect(Dir[testing_dir("_posts/*")].length).to eq(9)
      end

      # collision based on a permalink value, even though the path is different
      with_file_contents(testing_dir("_drafts/test--totally-different-path"), "permalink: /test-blog/test--existing-post\ntitle: A brand new post\npublish: now\n\nsome existing content") do
        expect { generate_site }.to raise_error(TestingSiteGenerationError, "failed to generate site")
        expect(Dir[testing_dir("_posts/*")].length).to eq(9)
      end
    end
  end

  it "will fail even if the base _config.yml permalink configuration changes" do
    begin
      FileUtils.mv(testing_dir("_config.yml"), testing_dir("_config.yml.temp"))

      with_file_contents(testing_dir("_config.yml"), "permalink: /:year/:title") do
        with_file_contents(testing_dir("_posts/#{Time.now.year}-#{Time.now.strftime("%m-%d")}-test--existing-post"), "title: Existing post\nCreated: 1960-12-31T05:06:07Z\n\nsome existing content") do
          with_file_contents(testing_dir("_posts/#{Time.now.year - 1}-#{Time.now.strftime("%m-%d")}-test--existing-post"), "title: Existing post\nCreated: 1960-12-31T05:06:07Z\n\nsome existing content") do
            expect { generate_site }.to_not raise_error

            File.open(testing_dir("_config.yml"), "w") { |f| f.puts("permalink: /new-permalink/:title") }

            expect { generate_site }.to raise_error(TestingSiteGenerationError, "failed to generate site")
          end
        end
      end
    ensure
      FileUtils.mv(testing_dir("_config.yml.temp"), testing_dir("_config.yml"))
    end
  end

  it "never touches _site/ if there would be a failure" do
    generate_site
    t1 = File.stat(testing_dir("_site")).ctime
    sleep 2

    generate_site
    t2 = File.stat(testing_dir("_site")).ctime
    expect(t2 - t1 > 1).to be_truthy
    sleep 1

    with_file_contents(testing_dir("_posts/#{Time.now.strftime("%Y-%m-%d")}-test--existing-post"), "title: Existing post\nCreated: 1960-12-31T05:06:07Z\n\nsome existing content") do
      with_file_contents(testing_dir("_drafts/test--existing-post"), "title: A brand new post\npublish: now\n\nsome existing content") do
        expect { generate_site }.to raise_error(TestingSiteGenerationError)

        expect(File.stat(testing_dir("_site")).ctime).to eq(t2)
      end
    end
  end
end
