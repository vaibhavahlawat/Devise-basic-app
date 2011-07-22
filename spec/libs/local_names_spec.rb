require File.expand_path('../../spec_helper', __FILE__)

# class including modules under test
class ClassWithLocalNames
  attr_accessor :logger
  include LocalNames
end

def valid_yaml
return <<YAML
---
names:
  Hash : this is a Hash
  someString : a string replacement
YAML
end

def invalid_yaml
  return "gobbledy guck"
end

describe LocalNames do
  before(:each) do
    @class_with_local_names = ClassWithLocalNames.new
    @logger = mock("Logger")
    @class_with_local_names.logger=@logger
    @mock_file = mock("File")
  end
  describe "Loading local names from a file config/local_names.yml" do
    describe "When the config file is missing" do
      before(:each) do
        File.stub!(:open).and_raise(Errno::ENOENT)
      end
      it "should not cause an error, but should report a warning" do
        @logger.should_receive(:warn)
        @class_with_local_names.load_names
      end
    end

    describe "When the local names file is invalid" do
      before(:each) do
        File.stub!(:open).and_return(@mock_file)
      end
      it "should not cause an error, but should produce a warning message" do
        @mock_file.should_receive(:read).and_return(invalid_yaml)
        @logger.should_receive(:warn)
        @class_with_local_names.load_names
      end
    end
  end 
  
  describe "Looking up local names" do
    before(:each) do
      File.stub!(:open).and_return(@mock_file)
      @mock_file.should_receive(:read).and_return(valid_yaml)
      @class_with_local_names.load_names
    end
    it "should have local names" do
      @class_with_local_names.local_names.should_not be_nil
    end
    describe "Asking for local names" do
      describe "When a local replacement has been defined" do
        it "should use the replacement" do
          @class_with_local_names.local_name_for({}).should == "this is a Hash"
          @class_with_local_names.local_name_for("someString").should == "a string replacement"
        end
      end
      describe "When no local replacement has been defined" do
        describe "When the caller specifies a default value" do  
          it "should use the default replacement value" do
            @class_with_local_names.local_name_for(self,"default").should == "default"
          end
        end
        describe "When the caller doesn't specify a default" do
          it "should use the titlecased human readable class name" do
            @class_with_local_names.local_name_for(@class_with_local_names).should == "Class With Local Names"
          end
        end
      end
    end
  end

end
