class Serif::Commands
  def exit(code)
    "Fake exit with code #{code}"
  end
end

RSpec.describe Serif::Commands do
  def expect_method_call(arg, method)
    c = Serif::Commands.new([arg])
    expect(c).to receive(method)
    capture_stdout { c.process }
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
      allow(Serif::Site).to receive(:generation_called)
      allow_any_instance_of(Serif::Site).to receive(:generate) { Serif::Site.generation_called }

      # if this is called, it means any instance of Site had #generate called.
      expect(Serif::Site).to receive(:generation_called)

      Serif::Commands.new([]).generate_site("anything")
    end

    context "with a conflict" do
      def conflicting_generate_command
        a = b = double("")
        allow(a).to receive(:url) { "/foo" }
        allow(b).to receive(:url) { "/foo" }
        allow(a).to receive(:path) { "/anything" }
        allow(b).to receive(:path) { "/anything" }

        # any non-nil value will do
        allow_any_instance_of(Serif::Site).to receive(:conflicts) { { "/foo" => [a, b] } }

        command = Serif::Commands.new([])
        command.generate_site(testing_dir)
        expect(command).to receive(:exit)
        command
      end

      it "exits" do
        capture_stdout { conflicting_generate_command.process }
      end

      it "prints the urls that conflict" do
        output = capture_stdout { conflicting_generate_command.process }
        expect(output).to match(/Conflicts at:\n\n\/foo\n\t\/anything\n\t\/anything/)
      end
    end
  end
end
