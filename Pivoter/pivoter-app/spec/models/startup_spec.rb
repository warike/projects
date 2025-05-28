require 'spec_helper'

describe Startup do

  describe "creation" do

    context "valid attributes" do

      it "should be valid" do
        startup = FactoryGirl.build(:startup)

        startup.should be_valid
      end

    end

    context "invalid attributes" do

      it "should not be valid" do
        startup = FactoryGirl.build(:startup, name: "")

        startup.should_not be_valid
      end

    end

  end

end