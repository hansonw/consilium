require 'spec_helper'

describe Client do
	before :each do
		@company = Company.new #("Title", "Author", :category)
	end

	describe "#new" do
		it "returns a new company object" do
			@company.should be_an_instance_of Company
		end

	end
end