# To tun test go to C:\consilium\app\models and type:rspec client_change_spec.rb
# C:\consilium\app\models>rspec client_change_spec.rb
# require_relative '../../../app/models/client_change'
require './spec_helper'

describe ClientChange do
	before :each do
		@clientChange = ClientChange.new
		@clientChange.stub(:errors).and_return({"test" => []})
	end

	describe "#new" do
		it "does not have simple testing working" do
			@clientChange.seven.should eq(7)
		end

	end
	describe "#self" do
		it "has value_equals 1st exit not work" do
			ClientChange.value_equals(nil, "not nil").should eq(false)
		end
		it "has value_equals 2nd exit not work" do
			ClientChange.value_equals(nil, nil).should eq(true)
		end
		it "has value_equals 13rd exit not work" do
			ClientChange.value_equals("not null", "not nil").should eq(false)
		end
	end
end
