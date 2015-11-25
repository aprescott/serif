RSpec.describe Serif::Placeholder do
  describe ".substitute" do
    specify { expect(Serif::Placeholder.substitute("foo", {})).to eq("foo") }
    specify { expect(Serif::Placeholder.substitute(nil, {})).to eq(nil) }

    it "makes substitutions using placeholders given by colons" do
      expect(Serif::Placeholder.substitute("foo :bar baz", "bar" => "a new value")).to eq("foo a new value baz")
      expect(Serif::Placeholder.substitute("foo:bar baz", "bar" => "a new value")).to eq("fooa new value baz")
      expect(Serif::Placeholder.substitute(":bar :bar :bar", "bar" => "123")).to eq("123 123 123")
      expect(Serif::Placeholder.substitute("bar :bar bar", "bar" => "123")).to eq("bar 123 bar")
      expect(Serif::Placeholder.substitute("bar:barbar", "bar" => "123")).to eq("bar123bar")
      expect(Serif::Placeholder.substitute(":x_y_z", "x_y_z" => "123")).to eq("123")
    end

    it "does not make any in-place modifications to the input arguments" do
      str = "some :foo string"
      parts = { "foo" => "1" }

      Serif::Placeholder.substitute(str, parts)

      expect(str).to eq(str)
      expect(parts).to eq(parts)
    end
  end
end
