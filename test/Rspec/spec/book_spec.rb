require 'spec_helper'
 
describe Book do
	before :each do
		@book = Book.new #("Title", "Author", :category)
	end

	describe "#new" do
		it "returns a new book object" do
			@book.should be_an_instance_of Book
		end

	    it "takes three parameters and returns a Book object" do
	        book = Book.new #"Title", "Author"
	        book.should_not be_an_instance_of Book
	    end
	end
end