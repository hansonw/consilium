# To tun test go to C:\consilium\app\models and type:rspec client_spec.rb
# C:\consilium\app\models>rspec client_spec.rb
# require_relative '../../../app/models/client'
require './spec_helper'

describe Client do
	before :each do
		@client = Client.new
		@client.stub(:errors).and_return({"test" => []})
	end

	describe "#new" do
		it "does not have simple testing working" do
			@client.seven.should eq(7)
		end

		it "does not have number input fields working" do
			def fielder 
				{
			      :name => 'Number Test',
			      :id => 'numberTest',
			      :placeholder => 'Placeholder',
			      :type => 'number',
			    }
			end
			@client.validate_value('Number Test', fielder, "1234").should eq(1234)
		end

		it "does not have the number field output error with invalid input format" do
			def fielder 
				{
			      :name => 'Number Is Number',
			      :id => 'numberNotLeterTest',
			      :placeholder => 'Placeholder',
			      :type => 'number',
			    }
			end
			@client.validate_value('test', fielder, "word")
			@client.errors["test"].should include('must be an integer')
		end

		it "does not have text input fields working" do
			def fielder 
				{
			      :name => 'Text Test',
			      :id => 'textTest',
			      :placeholder => 'Placeholder',
			      :type => 'text',
			    }
			end
			@client.validate_value('Text Test', fielder, "Hello World").should eq("Hello World")
		end

		it "does not show an error message if required fields are not filled" do
			def fielder 
				{
			      :name => 'Required Test',
			      :id => 'fieldRequired',
			      :placeholder => 'Placeholder',
			      :type => 'text',
			      :required => true,
			    }
			end
			@client.validate_value('test', fielder, "")
			@client.errors["test"].should include('is required')
		end

		it "does not have phone input fields working properly" do
			def fielder 
				{
			      :name => 'Phone',
			      :id => 'phoneOne',
			      :placeholder => 'Area code - phone #, ext #',
			      :type => 'phone',
			    }
			end
			@client.validate_value('Phone Test', fielder, "123-456.7890").should eq("123-456.7890")
		end

		it "does not have phone field output error with invalid input format" do
			def fielder 
				{
			      :name => 'Phone Valid Test',
			      :id => 'phoneValidTest',
			      :placeholder => 'Area code - phone #, ext #',
			      :type => 'phone',
			    }
			end
			@client.validate_value('test', fielder, "123")
			@client.errors["test"].should include('not valid phone number')
		end

		it "does not have email input fields working properly" do
			def fielder 
				{
			      :name => 'Email',
			      :id => 'emailAddress',
			      :placeholder => 'Email (ex. john@consilium.ca)',
			      :type => 'email',
			    }
			end
			@client.validate_value('Email Test', fielder, "test@test.com").should eq("test@test.com")
		end

		it "does not have email field output error with invalid input format" do
			def fielder 
				{
			      :name => 'Email Format Error',
			      :id => 'emailValidTest',
			      :placeholder => 'Area code - phone #, ext #',
			      :type => 'email',
			    }
			end
			@client.validate_value('test', fielder, "123")
			@client.errors["test"].should include('not valid email')
		end

		it "does not have testbox input fields working properly" do
			def fielder 
				{
		          :name => 'Description of operations',
		          :id => 'descriptionOperations',
		          :placeholder => 'Description of operations',
		          :type => 'textbox',
		        }
			end
			@client.validate_value('Textbox Test', fielder, "Hello World").should eq("Hello World")
		end

		it "does not have date input fields working properly" do
			def fielder 
				{
		          :name => 'Date Test',
		          :id => 'dateTest',
		          :type => 'date',
		        }
			end
			@client.validate_value('Date Test', fielder, "Hello World").should eq("Hello World")
			# This date input works, but should it... Really, should it?
		end

		it "does not have currency input fields working properly" do
			def fielder 
				{
		          :name => 'Currency Test',
		          :id => 'currencyTest',
		          :placeholder => '$ CAN (ex. 111.11)',
		          :type => 'currency',
		        }
			end
			@client.validate_value('Currency Test', fielder, "1111.11").should eq("1111.11")
		end

		it "does not have currency field output error with invalid input format" do
			def fielder 
				{
		          :name => 'Currency Valid Test',
		          :id => 'currencyValidTest',
		          :placeholder => '$ CAN (ex. 111.11)',
		          :type => 'currency',
		        }
			end
			@client.validate_value('test', fielder, "word")
			@client.errors["test"].should include('not valid currency format')
		end

		it "does not have dropdown input fields working properly" do
			def fielder 
				{
			      :name => 'Dropdown Test',
			      :id => 'dropdownTest',
			      :type => 'dropdown',
			      :options => [
			        'Option1',
			        'Option2',
			      ]
			    }
			end
			@client.validate_value('Dropdown Test', fielder, "Option1").should eq("Option1")
		end

		it "does not have radio input fields working properly" do
			def fielder 
				{
		          :name => 'Radio Test',
		          :id => 'radioTest',
		          :type => 'radio',
		          :options => {
		            'optionOne' => 'Option1',
		            'optionTwo' => 'Option2',
		          }
		        }
			end
			@client.validate_value('radioTest', fielder, "optionOne").should eq("optionOne")
		end

		it "does not have radio/dropdown field output error with invalid input" do
			def fielder 
				{
		          :name => 'radioTest',
		          :id => 'prevPremiumMonthlyOrAnnual',
		          :type => 'radio',
		          :options => {
		            'optionOne' => 'Option1',
		            'optionTwo' => 'Option2',
		          }
		        }
			end
			@client.validate_value('test', fielder, "optionOverNineThousand")
			@client.errors["test"].should include('is not one of the provided options')
		end

		it "does not have checkbox input fields working properly" do
			def fielder 
				{
		          :name => 'Checkbox Test',
		          :id => 'inspection',
		          :type => 'checkbox',
		          :options => {
		          	'optionOne' => 'Option1',
		            'optionTwo' => 'Option2',
		          }
		        }
			end
			@client.validate_value('Checkbox Test', fielder, {"optionOne" => true}).should eq({"optionOne" => true})
		end

		it "does not have checkbox field output error with invalid input" do
			def fielder 
				{
		          :name => 'Checkbox Test',
		          :id => 'inspection',
		          :type => 'checkbox',
		          :options => {
		          	'optionOne' => 'Option1',
		            'optionTwo' => 'Option2',
		          }
		        }
			end
			@client.validate_value('test', fielder, {"optionOverNineThousand" => true}) #.should eq({"optionOverNineThousand" => true})
			@client.errors["test"].should include('must be a checkbox value')
		end
		# # these have an issue with ends_with? being undifined. hanson's plan might fix it
		# it "trial1" do
		# 	Client.expand_fields.should eq(nil)
		# end
		# it "trial2" do
		# 	@client.valid?().should eq(nil)
		# end
		# it "trial3" do
		# 	@field = Client.field
		# 	@client.validate_field(@field)
		# end
	end
end
