class Client
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  FIELDS = [
    {
      :name => 'Name',
      :id => 'name',
      :placeholder => 'Firstname Lastname',
      :type => 'text',
      :required => true,
    },
    {
      :name => 'Address',
      :id => 'address',
      :placeholder => 'Address (apt., suite, bldg.)',
      :type => 'text',
      :required => true,
    },
    {
      :name => 'City and Province',
      :id => 'cityAndProvince',
      :placeholder => 'City, Province',
      :type => 'text',
      :required => true,
    },
    {
      :name => 'Phone',
      :id => 'phone',
      :placeholder => 'Area code - phone #, ext #',
      :type => 'phone',
      :required => true,
    },
    {
      :name => 'Client Contacts',
      :id => 'clientContacts',
      :type => [
        {
          :name => 'Name',
          :id => 'name',
          :placeholder => 'Firstname Lastname',
          :type => 'text',
          :required => true,
        },
        {
          :name => 'Title',
          :id => 'title',
          :placeholder => 'Mr./Mrs./Dr. (etc)',
          :type => 'text',
        },
      ],
    },
    {
      :name => 'Business Ops',
      :id => 'businessOps',
      :type => [
        {
          :name => 'Name',
          :id => 'name',
          :placeholder => 'Firstname Lastname',
          :type => 'text',
          :required => true,
        },
      ],
    },
    {
      :name => 'Claims Info',
      :id => 'claimsInfos',
      :type => [
        {
        },
      ],
    },
    {
      :name => 'Prev. Policy Info',
      :id => 'prevPolicyInfos',
      :type => [
        {
        },
      ],
    },
    {
      :name => 'Liability Info',
      :id => 'liabilityInfos',
      :type => [
        {
        },
      ],
    },
    {
      :name => 'Misc. Notes',
      :id => 'miscNotes',
      :type => [
        {

        },
      ],
    },
    {
      :name => 'Coverage Schedule',
      :id => 'coverageSchedules',
      :type => [
        {

        },
      ],
    },
    {
      :name => 'Properties',
      :id => 'properties',
      :type => [
        {
        },
      ],
    },
    {
      :name => 'Umbrella/Machinery',
      :id => 'umbrellaMachinery',
      :type => [
        {
        },
      ],
    },
    {
      :name => 'Photos',
      :id => 'photos',
      :type => [
      ],
    },
  ]
end
