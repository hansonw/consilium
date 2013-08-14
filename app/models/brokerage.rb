require 'consilium_fields'
require 'consilium_field_references'

class Brokerage
  include Mongoid::Document
  include Mongoid::Timestamps
  include ConsiliumFields
  include ConsiliumFieldReferences

  has_many :clients
  has_many :users

  field :name, type: String
  field :address, type: String
  field :website, type: String
  field :phone, type: String
  field :fax, type: String
  field :clients, type: Integer
  field :employees, type: Integer

  field :contacts, type: Array

  FIELDS = [
    {
      :id => 'name',
      :name => 'Name',
      :placeholder => 'e.g. Insurance Company Inc.',
      :type => 'text',
    },
    {
      :id => 'address',
      :name => 'Address',
      :placeholder => 'e.g. 123 Main Street, Toronto ON A1B 3C4',
      :type => 'text',
    },
    {
      :id => 'website',
      :name => 'Website',
      :placeholder => 'e.g. www.insurancecompany.com',
      :type => 'text',
    },
    {
      :id => 'phone',
      :name => 'Phone',
      :placeholder => '(Area Code) - Number (ext.)',
      :type => 'phone'
    },
    {
      :id => 'fax',
      :name => 'Fax',
      :placeholder => '(Area Code) - Number',
      :type => 'phone'
    },
    {
      :id => 'contacts',
      :name => 'Contacts',
      :type => [
        {
          :id => 'name',
          :name => 'Name',
          :placeholder => 'Name',
          :required => true,
          :type => 'text',
          :primary => true,
        },
        {
          :id => 'title',
          :name => 'Title',
          :placeholder => 'e.g. Producer, Marketer, Customer Service',
          :required => true,
          :type => 'text',
          :primary => true,
        },
        {
          :id => 'email',
          :name => 'Email',
          :placeholder => 'e.g. john@consilium.ca',
          :type => 'email',
        },
        {
          :id => 'phone',
          :name => 'Phone',
          :placeholder => '(Area Code) - Number (ext.)',
          :type => 'phone',
        },
        {
          :id => 'description',
          :name => 'Description of role',
          :placeholder => 'Description of role in brokerage',
          :type => 'textbox'
        },
      ],
    },
    {
      :id => 'users',
      :name => 'Users',
      :type => User,
    },
  ]
end
