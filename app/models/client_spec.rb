# To tun test go to C:\consilium\app\models and type:rspec client_spec.rb
# C:\consilium\app\models>rspec client_spec.rb
require './client'
require 'yaml'

describe Client do
	before :each do
		@client = Client.new
		@client.stub(:errors).and_return({"test" => []})
	end

	describe "#new" do
		it "returns a new company object" do
			@client.seven.should eq(4)
		end

		it "does not have text input fields working" do
			def fielder 
				{
			      :name => 'Text Test',
			      :id => 'company',
			      :placeholder => 'Placeholder',
			      :type => 'text',
			      :required => true,
			    }
			end
			@client.validate_value('company', fielder, "Bobs Build").should eq("Bobs Build")
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

		it "does not have phone input fields working properly" do
			def fielder 
				{
			      :name => 'Phone',
			      :id => 'phoneOne',
			      :placeholder => 'Area code - phone #, ext #',
			      :type => 'phone',
			    }
			end
			@client.validate_value('Dropdown Test', fielder, "1234567890").should eq("1234567890")
		end

		it "should fail if phone validator is working properly" do
			def fielder 
				{
			      :name => 'Phone two',
			      :id => 'phoneTwo',
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

		it "does not have testbox input fields working properly" do
			def fielder 
				{
		          :name => 'Description of operations',
		          :id => 'descriptionOperations',
		          :placeholder => 'Description of operations',
		          :type => 'textbox',
		          :boxRows => 5,
		        }
			end
			@client.validate_value('Textbox Test', fielder, "Hello World").should eq("Hello World")
		end

		it "does not have date input fields working properly" do
			def fielder 
				{
		          :name => 'Loss Date',
		          :id => 'lossDate',
		          :type => 'date',
		          :required => true,
		        }
			end
			@client.validate_value('Textbox Test', fielder, "Hello World").should eq("Hello World")
		end

		it "does not have currency input fields working properly" do
			def fielder 
				{
		          :name => 'Reserve',
		          :id => 'reserve',
		          :placeholder => '$ CAN (ex. 111.11)',
		          :type => 'currency',
		        }
			end
			@client.validate_value('Textbox Test', fielder, "1111.11").should eq("1111.11")
		end

		it "does not have radio input fields working properly" do
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
			@client.validate_value('radioTest', fielder, "optionOne").should eq("optionOne")
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

	end
end


# {
#       :name => 'Company',
#       :id => 'company',
#       :placeholder => 'Name of Company',
#       :type => 'text',
#       :required => true,
#     }