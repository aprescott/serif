RSpec.describe Serif::Site do
  subject { Serif::Site.new("a/source/directory") }

  describe "#latest_update_time" do
    let(:posts) do
      [
        double(updated: 2),
        double(updated: 1),
        double(updated: 4),
        double(updated: 3)
      ]
    end

    before do
      allow(subject).to receive(:posts).and_return(posts)
    end

    its(:latest_update_time) { should eq(4) }

    context "when there are no posts" do
      let(:posts) { [] }

      its(:latest_update_time) { should be_within(1).of(Time.now) }
    end
  end
end
