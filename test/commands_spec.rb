require "test_helper"

class Serif::Commands
  def exit(code)
    "Fake exit with code #{code}"
  end
end

describe Serif::Commands do
  def expect_method_call(arg, method)
    c = Serif::Commands.new([arg])
    c.should_receive(method)
    c.process
  end

  describe "#process" do
    it "takes -h and --help and calls print usage" do
      %w[-h --help].each do |cmd|
        expect_method_call(cmd, :print_help)
      end
    end

    {
      "admin"    => :initialize_admin_server,
      "dev"      => :initialize_dev_server,
      "new"      => :produce_skeleton,
      "generate" => :generate_site
    }.each do |command, meth|
      it "takes the command '#{command}' and runs #{meth}" do
        expect_method_call(command, meth)
      end
    end

    it "exits on help" do
      expect_method_call("-h", :exit)
    end
  end

  describe "#generate_site" do
    it "calls Site#generate" do
      Serif::Site.stub(:generation_called)
      Serif::Site.any_instance.stub(:generate) { Serif::Site.generation_called }

      # if this is called, it means any instance of Site had #generate called.
      Serif::Site.should_receive(:generation_called)

      Serif::Commands.new([]).generate_site("anything")
    end
  end
end