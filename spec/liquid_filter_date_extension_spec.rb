require "spec_helper"

describe Liquid::StandardFilters do
  subject do
    o = Object.new
    o.extend(Liquid::StandardFilters)
    o
  end

  describe "#date" do
    it "accepts 'now' for the current time" do
      subject.date("now", "%Y").should == Time.now.year.to_s
    end
  end
end