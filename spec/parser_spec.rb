require 'spec_helper'

describe Woof::Parser do
  let(:data_directory) { File.expand_path(File.join(File.dirname(__FILE__), 'data')) }
  let(:parser) { Woof::Parser.new(File.join(data_directory, 'iris.arff')) }
  let(:parsed_file) { parser.parse }
  it "should return a valid object when given a file path" do
    parser.should_not be_nil
  end

  it "should parse into an ArffFile object" do
    file = parser.parse
    file.should_not be_nil
  end

  it "should keep continuous values continuous by default" do
    file = parser.parse
    # p file
    file.attributes[0][:type].should == "numeric"
  end

  it "should discretize values upon parsing upon request" do
    file = parser.parse({ discretize: true })
    file.attributes[0][:type].should == "string"
  end

  it "should make all attributes continuous on request" do
    parsed_file.continuize!
    parsed_file.attributes[-1][:type].should == "numeric"
    parsed_file.data[0][parsed_file.attributes[-1][:name]].should be_instance_of(Fixnum)
  end

  it "should allow you to get the values for the class" do
    parsed_file.get_class_values.should == %w(Iris-setosa Iris-versicolor Iris-virginica)
  end

  describe "#get_training_and_validation_sets" do
    let(:split_set) { parsed_file.get_training_and_validation_sets(0.7, 0.3) }
    it "should split the dataset into a training and verification set" do
      split_set.size.should == 2
      size = parsed_file.data.length
      split_set[0].data.length.should == (size * 0.7).floor
      split_set[1].data.length.should == (size * 0.3).floor
    end

    it "should return the data in random order" do
      old_data = parsed_file.data
      new_data = split_set[0].data + split_set[1].data
      #they contain the same data but in a different order
      old_data.should_not == new_data
    end

    it "returns an array of arff files with the same number of elements as the original arff_file" do
      size = parsed_file.data.length
      new_size = split_set.inject(0) { |memo, arff| memo += arff.data.length }
      size.should == new_size
    end
  end
end
