require 'spec_helper'

describe Woof::ArffFile do
  let(:parsed_file) { Woof::Parser.new(File.expand_path(File.join(File.dirname(__FILE__), 'data', 'iris.arff'))).parse }

  it "should work" do
    parsed_file.should_not be_nil
  end

  describe "#-" do
    it "returns a new arfffile without common dataset items" do
      parsed_file.-(parsed_file).length.should == 0
    end
  end

  describe "#[]" do
    it "returns the same results for accessing single items as the underlying data array does" do
      parsed_file.data.each_index do |i|
        parsed_file[i].data.should == parsed_file.data[i]
      end
    end

    it "takes range objects as well" do
      parsed_file.data[0..-1].should == parsed_file[0..-1].data
    end
  end
end
