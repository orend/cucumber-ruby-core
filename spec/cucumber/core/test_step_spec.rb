require 'cucumber/core/test_step'

module Cucumber::Core
  describe TestStep do

    describe "executing" do
      let(:mappings) { stub }
      let(:ast_step) { stub }

      context "when a passing mapping exists for the step" do
        before do
          mappings.stub(:execute).with(ast_step).and_return(mappings)
        end

        it "returns a passing result" do
          test_step = TestStep.new([ast_step])
          test_step.execute(mappings).should == Result::Passed.new(test_step)
        end
      end

      context "when a failing mapping exists for the step" do
        before do
          mappings.stub(:execute).with(ast_step).and_raise(StandardError, 'failed')
        end

        it "returns a failing result" do
          test_step = TestStep.new([ast_step])
          test_step.execute(mappings).should == Result::Failed.new(test_step)
        end
      end

    end

    describe "describing itself" do
      it "delegates to each of its parents in turn" do
        feature, scenario, step = stub, stub, stub
        visitor = stub
        args = stub
        feature.should_receive(:describe_to).with(visitor, args)
        scenario.should_receive(:describe_to).with(visitor, args)
        step.should_receive(:describe_to).with(visitor, args)
        test_step = TestStep.new([feature, scenario, step])
        test_step.describe_to(visitor, args)
      end
    end
  end
end
