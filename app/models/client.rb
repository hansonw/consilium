class Client
  # include Mongoid::Document
  # include Mongoid::Timestamps
  # include Mongoid::Attributes::Dynamic

  # has_many :client_changes, dependent: :delete
  # has_many :documents, dependent: :delete
  # ^ These need to be commented to run Rspec for some unknown reason

  FIELDS = [
    {
      :name => 'Company',
      :id => 'company',
      :placeholder => 'Name of Company',
      :type => 'text',
      :required => true,
    },
    {
      :name => 'Name',
      :id => 'name',
      :placeholder => 'Firstname Lastname',
      :type => 'text',
      :required => true,
    },
    {
      :name => 'Form of business',
      :id => 'businessType',
      :type => 'dropdown',
      :options => [
        'Individual',
        'Partnership or Limited Partnership',
        'Joint Venture',
        'Trust',
        'Limited Liability Company',
        'Corporation',
      ]
    },
    {
      :name => 'Account Number',
      :id => 'accountNumber',
      :placeholder => 'Account Number',
      :type => 'text',
    },
    {
      :name => 'Address',
      :id => 'address',
      :placeholder => 'Address (apt., suite, bldg.)',
      :type => 'text',
    },
    {
      :name => 'City',
      :id => 'city',
      :placeholder => 'City',
      :type => 'text',
    },
    {
      :name => 'Province',
      :id => 'province',
      :placeholder => 'Province',
      :type => 'text',
    },
    {
      :name => 'Country',
      :id => 'country',
      :placeholder => 'Country',
      :type => 'text',
    },
    {
      :name => 'Postal Code',
      :id => 'postalCode',
      :placeholder => 'e.g. A1B 2C3',
      :type => 'text',
    },
    {
      :name => 'Web Site',
      :id => 'website',
      :placeholder => 'Website (ex. www.consilium.com)',
      :type => 'text',
    },
    {
      :name => 'Phone',
      :id => 'phone',
      :placeholder => 'Area code - phone #, ext #',
      :type => 'phone',
    },
    {
      :name => 'Fax',
      :id => 'fax',
      :placeholder => 'Area code - phone #, ext #',
      :type => 'phone',
    },
    {
      :name => 'Email',
      # TODO: if id is set to email, the text resets after it is saved.
      :id => 'emailAddress',
      :placeholder => 'Email (ex. john@consilium.ca)',
      :type => 'email',
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
        {
          :name => 'Position',
          :id => 'position',
          :type => 'dropdown',
          :placeholder => '',
          :options => [
            'Accountant',
            'CEO',
            'Insured',
            'Manager',
            'Owner',
            'President',
            'Principal',
            'Secretary',
            'Vice President',
            'Other',
          ],
          :otherPlaceholder => 'Specify',
        },
        {
          :name => 'Phone',
          :id => 'phone',
          :placeholder => 'Area code - phone #, ext #',
          :type => 'phone',
        },
        {
          :name => 'Email',
          :id => 'email',
          :placeholder => 'Email (ex. john@consilium.ca)',
          :type => 'email',
        },
        {
          :name => 'Other',
          :id => 'other',
          :placeholder => 'Main, Direct, Toll, Fax, Pager, Cell, Home',
          :type => 'text',
        },
      ],
    },
    {
      :name => 'Business Ops',
      :id => 'businessOp',
      :type => [
        {
          :name => 'Industry Code',
          :id => 'industryCode',
          :placeholder => 'Industry Code (ex. 111111)',
          :type => 'text',
        },
        {
          :name => 'Description of operations',
          :id => 'descriptionOperations',
          :placeholder => 'Description of operations',
          :type => 'textbox',
          :boxRows => 5,
        },
      ],
    },
    {
      :name => 'Claims Info',
      :id => 'claimsInfos',
      :type => [
        {
          :name => 'Loss Date',
          :id => 'lossDate',
          :type => 'date',
          :required => true,
        },
        {
          :name => 'Type of Claim',
          :id => 'claimType',
          :placeholder => '(ex. Commercial)',
          :type => 'text',
        },
        {
          :name => 'Description',
          :id => 'description',
          :placeholder => 'Description',
          :type => 'textbox',
          :boxRows => 2,
        },
        {
          :name => 'Amount Paid',
          :id => 'amountPaid',
          :placeholder => '$ CAN (ex. 111.11)',
          :type => 'currency',
        },
        {
          :name => 'Reserve',
          :id => 'reserve',
          :placeholder => '$ CAN (ex. 111.11)',
          :type => 'currency',
        },
      ],
    },
    {
      :name => 'Prev. Policy Info',
      :id => 'prevPolicyInfo',
      :type => [
        {
          :name => 'Insurer',
          :id => 'prevInsurer',
          :placeholder => 'Name',
          :type => 'text',
        },
        {
          :name => 'Broker',
          :id => 'prevBroker',
          :placeholder => 'Some Insurance Brokers Inc.',
          :type => 'text',
        },
        {
          :name => 'Policy Number',
          :id => 'prevPolicyNumber',
          :placeholder => '# (ex. AAA1111111)',
          :type => 'text',
        },
        {
          :name => 'Premium',
          :id => 'prevPremium',
          :placeholder => '$ CAN (ex. 111.11)',
          :type => 'currency',
        },
        {
          :name => '',
          :id => 'prevPremiumMonthlyOrAnnual',
          :type => 'radio',
          :options => {
            'annually' => 'Annually',
            'monthly' => 'Monthly',
          },
        },
        {
          :name => 'Prev. Term Start Date',
          :id => 'prevTermStart',
          :type => 'date',
        },
        {
          :name => 'Prev. Term End Date',
          :id => 'prevTermEnd',
          :type => 'date',
        },
        {
          :name => 'Was renewal offered',
          :id => 'renewalOffered',
          :type => 'radio',
          :options => {
            'yes' => 'Yes',
            'no' => 'No',
          },
        },
        {
          :name => 'If renewal was not offered, explain here',
          :id => 'renewalExplanation',
          :placeholder => 'Explanation',
          :type => 'textbox',
          :if => '!renewalOffered',
          :boxRows => 6,
        },
      ],
    },
    {
      :name => 'Liability Info',
      :id => 'liabilityInfo',
      :type => [
        {
          :name => 'In Business Since',
          :id => 'businessStartDate',
          :type => 'date',
        },
        {
          :name => 'Full Time Employees',
          :id => 'fullTimeEmployees',
          :placeholder => '#',
          :type => 'text',
        },
        {
          :name => 'Part Time Employees',
          :id => 'partTimeEmployees',
          :placeholder => '#',
          :type => 'text',
        },
        {
          :name => 'Covered by',
          :id => 'covered',
          :placeholder => '',
          :type => 'dropdown',
          :options => [
            'WSIB',
            'Other',
          ],
          :otherPlaceholder => 'Specify',
        },
        {
          :name => 'Annual gross receipts',
          :id => 'annualGrossReceipts',
          :placeholder => '$ CAN (ex. 111.11)',
          :type => 'currency',
        },
        {
          :name => 'Canadian %',
          :id => 'canadianPercent',
          :placeholder => '% (ex. 11)',
          :type => 'text',
        },
        {
          :name => 'US. %',
          :id => 'americanPercent',
          :placeholder => '% (ex. 11)',
          :type => 'text',
        },
        {
          :name => 'Foreign %',
          :id => 'foreignPercent',
          :placeholder => '% (ex. 11)',
          :type => 'text',
        },
        {
          :name => 'Annual Payroll',
          :id => 'annualPayroll',
          :placeholder => '$ CAN (ex. 111.11)',
          :type => 'currency',
        },
        # Marc doesn't have these; dunno if these will be necessary at some point
        # {
        #   :name => 'Units',
        #   :id => 'units',
        #   :placeholder => 'Amount of units',
        #   :type => 'text',
        # },
        # {
        #   :name => 'Base Units',
        #   :id => 'baseUnits',
        #   :placeholder => 'Base units',
        #   :type => 'text',
        # },
        # {
        #   :name => 'Is there any liquor liability',
        #   :id => 'liquorLiability',
        #   :type => 'radio',
        #   :options => {
        #     'yes' => 'Yes',
        #     'no' => 'No',
        #   },
        # },
        # {
        #   :name => 'Receipt Splits: Liquor',
        #   :id => 'receiptSplitsLiquor',
        #   :placeholder => '$ CAN (ex. 111.11)',
        #   :type => 'currency',
        #   :if => 'liquorLiability'
        # },
        # {
        #   :name => 'Receipt Splits: Food',
        #   :id => 'receiptSplitsFood',
        #   :placeholder => '$ CAN (ex. 111.11)',
        #   :type => 'currency',
        #   :if => 'liquorLiability'
        # },
        # {
        #   :name => 'Receipt Splits: Other',
        #   :id => 'receiptSplitsOther',
        #   :placeholder => '$ CAN (ex. 111.11)',
        #   :type => 'currency',
        #   :if => 'liquorLiability'
        # },
      ],
    },
    {
      # TODO: Move this into Liability Information as a collection within a section.
      :name => 'Exposure/Receipts',
      :id => 'exposureOrReceipts',
      :type => [
        {
          :name => 'Operation or Product Type',
          :id => 'operationOrProductType',
          :type => 'text',
          :placeholder => 'Operation or product type',
        },
        {
          :name => 'Annual % or $',
          :id => 'annualPercentOrDollar',
          :type => 'text',
          :placeholder => '$ CAN (ex. 111.11) or % (ex. 48%)'
        },
        {
          :name => 'Change from Last Year',
          :id => 'changeFromLastYear',
          :type => 'text',
          :placeholder => '$ CAN (ex. 111.11) or % (ex. 48%)'
        },
      ],
    },
    {
      :name => 'Policy Info',
      :id => 'policyInfo',
      :type => [
        {
          :name => 'Period of Coverage From',
          :id => 'coverageFrom',
          :type => 'date',
        },
        {
          :name => 'Period of Coverage To',
          :id => 'coverageTo',
          :type => 'date',
        },
        {
          :name => 'Quote Required By',
          :id => 'requiredBy',
          :type => 'date',
        },
      ],
    },
    # Not in Marc's template.
    # {
    #   :name => 'Payment Info',
    #   :id => 'paymentInfo',
    #   :type => [
    #     {
    #       :name => 'Payment Type',
    #       :id => 'paymentType',
    #       :type => 'dropdown',
    #       :options => [
    #         'Company Bill',
    #         'Broker/Agent Bill',
    #         'Other',
    #       ],
    #     },
    #   ],
    # },
    {
      :name => 'Location Info',
      :id => 'locationInfos',
      :editHref => 'clients/edit/{{clientId}}/locationInfo/{{$index}}',
      :createHref => '#/clients/edit/{{client.id}}/locationInfo/',
      :type => [
        {
          :name => 'Location Number',
          :id => 'locationNumber',
          :placeholder => '# (ex. 1111)',
          :type => 'text',
        },
        {
          :name => 'This location is',
          :id => 'locationType',
          :type => 'dropdown',
          :placeholder => '',
          :options => [
            'Urban',
            'Rural',
          ],
        },
        {
          :name => 'Address',
          :id => 'locationAddress',
          :placeholder => 'Address (apt., suite, bldg.)',
          :type => 'text',
        },
        {
          :name => 'City',
          :id => 'locationCity',
          :placeholder => 'City',
          :type => 'text',
        },
        {
          :name => 'Country',
          :id => 'locationCountry',
          :placeholder => 'Country',
          :type => 'text',
        },
        {
          :name => 'Province/State',
          :id => 'locationProvinceState',
          :placeholder => 'Province/State',
          :type => 'text',
        },
        {
          :name => 'Postal Code',
          :id => 'locationPostalCode',
          :placeholder => '(ex. A1A 1A1)',
          :type => 'text',
        },
        {
          :name => '',
          :id => 'inspection',
          :type => 'checkbox',
          :options => {
            'yes' => 'This risk was not inspected',
          },
        },
        {
          :name => 'Date Inspected',
          :id => 'inspectionDate',
          :type => 'date',
          :if => '!inspection.yes',
        },
        {
          :name => 'Inspected by',
          :id => 'inspectedBy',
          :placeholder => 'Person/firm risk was inspected by',
          :type => 'text',
          :if => '!inspection.yes',
        },
        {
          :name => 'This risk is',
          :id => 'riskSeverity',
          :type => 'radio',
          :options => {
            'excellent' => 'Excellent',
            'veryGood' => 'Very Good',
            'good' => 'Good',
            'average' => 'Average',
            'fair' => 'Fair',
            'poor' => 'Poor',
          },
          :if => '!inspection.yes',
        },
        {
          :name => 'Scope of insured property',
          :id => 'scopeOfInsuredProperty',
          :type => 'text',
          :placeholder => 'e.g. equipment, stock, business interruption',
        },
        # {
        #   :name => 'Municipal Fire Zone',
        #   :id => 'municipalFireZone',
        #   :type => 'dropdown',
        #   :placeholder => 'Zone',
        #   :options => [
        #     'Zone 1',
        #     'Zone 2',
        #     'Zone 3',
        #     'Zone 4',
        #     'Other'
        #   ],
        #   :otherPlaceholder => 'Specify',
        # },
        # {
        #   :name =>'Fire Protection Grade',
        #   :id => 'fireGrade',
        #   :placeholder => 'Fire Protection Grade',
        #   :type => 'text',
        # },
        {
          :name => 'Risk Info',
          :id => 'riskInfo',
          :type => [
            {
              :name => 'Type',
              :id => 'riskInfoType',
              :type => 'dropdown',
              :placeholder => '(Risk Type)',
              :options => [
                'Commercial Building',
                'Commercial Equipment',
                'Commercial Stock',
                'Other Commercial Risk',
              ],
            },
            {
              :name => 'Notes',
              :id => 'riskInfoNotes',
              :placeholder => "Other useful info.",
              :type => 'textbox',
            },
            {
              :name => 'Limit',
              :id => 'riskInfoLimit',
              :placeholder => 'Limit',
              :type => 'text',
            },
            {
              :name => 'Stories',
              :id => 'constructionStories',
              :placeholder => '# of Floors',
              :type => 'text',
            },
            {
              :name => 'Year Built',
              :id => 'yearBuilt',
              :placeholder => '#',
              :type => 'text',
            },
            {
              :name => 'Area',
              :id => 'constructionArea',
              :placeholder => '# Only',
              :type => 'text',
            },
            {
              :name => 'Area Units',
              :id => 'constructionAreaUnit',
              :type => 'dropdown',
              :options => [
                'Sq. ft.',
                'Sq. m.',
              ],
            },
            {
              :name => 'Walls',
              :id => 'constructionWalls',
              :type => 'dropdown',
              :placeholder => 'Select a material..',
              :options => [
                'Poured Concrete',
                'HCB – Hollow Concrete Block',
                'Frame and all other',
                'Frame w/ brick veneer',
                'Frame metal clad',
                'Solid Brick',
                'Concrete panels on steel structure',
                'Steel on steel',
                'Metallic panels on steel structure',
                'Wood',
                'Fire resistive',
                'Non-combustible with masonry walls',
                'Non-combustible with non-masonry walls',
                'Masonry',
                'Masonry veneer',
                'Other',
              ],
            },
            {
              :name => 'Floors',
              :id => 'constructionFloors',
              :type => 'dropdown',
              :placeholder => 'Select a material..',
              :options => [
                'Poured concrete or fire resistive material',
                'Frame and all other',
                'Masonry',
                'Concrete panels on steel structure',
                'Masonry on wood structure or other combustible material',
                'Heavy Beam or Mill',
                'Non-combustible with masonry',
                'Non-combustible without masonry',
                'Wood',
                'Steel',
                'Brick or stone',
                'Other',
              ],
            },
            {
              :name => 'Basement',
              :id => 'constructionBasement',
              :type => 'dropdown',
              :placeholder => 'Select a material..',
              :options => [
                'Poured concrete',
                'HCB – Hollow concrete block',
                'No basement',
                'Fire resistive',
                'Non-combustible with masonry',
                'Non-combustible without masonry',
                'Masonry with combustible ceiling',
                'Masonry veneer',
                'Frame and all other',
                'Unfinished (crawl space)',
                'Other',
              ],
            },
            {
              :name => 'Roof',
              :id => 'constructionRoof',
              :type => 'dropdown',
              :placeholder => 'Select a material..',
              :options => [
                'Frame on steel joists',
                'Frame on wood joists',
                'Heavy beam or mill',
                'Poured concrete',
                'Steel Beam',
                'Steel Deck',
                'Other',
              ]
            },
            {
              :name => 'Roof Covering',
              :id => 'constructionRoofCovering',
              :type => 'dropdown',
              :placeholder => 'Select a material..',
              :options => [
                'Asphalt shingles',
                'Steel Deck',
                'Tar and gravel',
                'Concrete on steel structure',
                'Concrete Tiles',
                'Metal',
                'Wood shakes',
                'Tile',
                'Slate',
                'Rubber/Polymer',
                'Tar paper',
                'Plastic',
                'Glass dome/skylight',
                'Wood shingles',
                'Glass/poly on metal',
                'Other',
              ],
            },
            {
              :name => 'Electrical Type',
              :id => 'constructionElectrical',
              :type => 'dropdown',
              :placeholder => '',
              :options => [
                'Breakers',
                'Fuses',
                'Breakers & Fuses',
              ],
            },
            {
              :name => 'Plumbing Type',
              :id => 'constructionPlumbing',
              :type => 'dropdown',
              :placeholder => '',
              :options => [
                'Copper',
                'Copper/plastic PVC mix',
                'Lead',
                'Plastic (PVC or CVS)',
                'Galvanized',
                'Stainless Steel',
                'Steel',
                'Other',
              ],
            },
            {
              :name => 'Heating Type',
              :id => 'constructionHeating',
              :type => 'dropdown',
              :placeholder => '',
              :options => [
                'None',
                'Duct furnace',
                'Boiler',
                'Unit heaters',
                'Radiant',
                'Electric',
                'Heat pump',
                'Combined primary outside risk unit & inside auxiliary',
                'Wood burning kitchen stove',
                'Slow wood burning/air tight stove',
                'Furnace (central) with add-on wood burning unit',
                'Fireplace insert',
                'Furnace (central)',
                'Bi-energy/combination with wood',
                'Stove',
                'Solid fuel heating unit',
                '220 watt electric furnace',
                'Floor furnace',
                'Warm air',
                'Wood burning unit',
                'Wall furnace',
                'Space heater',
                'Magazine type coal burning stove',
                'Movable stoves',
                'Movable heaters',
                'Recessed heater',
                'Water heaters',
                'Pipeless warm air furnace',
                'Primary and auxillary',
                'Suspended heaters',
                'Roof mounted HVAC',
                'Geothermal',
                'Other (describe)',
              ]
            },
            {
              :name => 'Fuel',
              :id => 'constructionFuel',
              :type => 'dropdown',
              :placeholder => 'Fuel type',
              :options => [
                'Oil',
                'Natural gas',
                'Propane',
                'Steam',
                'Coal',
                'Wood',
                'Electric',
                'Solar',
                'Naptha gas',
                'Butane',
                'Combination – oil and wood',
                'Combination – electric and oil',
                'Other',
              ]
            },
            {
              :name => 'Renovations',
              :id => 'renovationsNoneKnown',
              :type => 'checkbox',
              :options => {
                'yes' => 'None Known',
              },
            },
            {
              :name => '',
              :id => 'renovationsElectrical',
              :type => 'checkbox',
              :options => {
                'yes' => 'Electrical',
              },
            },
            {
              :name => 'Year of Renovation',
              :id => 'renovationsElectricalYear',
              :type => 'text',
              :placeholder => '#',
              :if => 'renovationsElectrical.yes'
            },
            {
              :name => '',
              :id => 'renovationsElectricalCompletePartial',
              :type => 'radio',
              :options => {
                'complete' => 'Complete',
                'partial' => 'Partial',
              },
              :if => 'renovationsElectrical.yes'
            },
            {
              :name => '',
              :id => 'renovationsPlumbing',
              :type => 'checkbox',
              :options => {
                'yes' => 'Plumbing',
              },
            },
            {
              :name => 'Year of Renovation',
              :id => 'renovationsPlumbingYear',
              :type => 'text',
              :placeholder => '#',
              :if => 'renovationsPlumbing.yes',
            },
            {
              :name => '',
              :id => 'renovationsPlumbingCompletePartial',
              :type => 'radio',
              :options => {
                'complete' => 'Complete',
                'partial' => 'Partial',
              },
              :if => 'renovationsPlumbing.yes',
            },
            {
              :name => '',
              :id => 'renovationsHeating',
              :type => 'checkbox',
              :options => {
                'yes' => 'Heating',
              },
            },
            {
              :name => 'Year of Renovation',
              :id => 'renovationsHeatingYear',
              :type => 'text',
              :placeholder => '#',
              :if => 'renovationsHeating.yes',
            },
            {
              :name => '',
              :id => 'renovationsHeatingCompletePartial',
              :type => 'radio',
              :options => {
                'complete' => 'Complete',
                'partial' => 'Partial',
              },
              :if => 'renovationsHeating.yes',
            },
            {
              :name => '',
              :id => 'renovationsRoof',
              :type => 'checkbox',
              :options => {
                'yes' => 'Roof',
              },
            },
            {
              :name => 'Year of Renovation',
              :id => 'renovationsRoofYear',
              :type => 'text',
              :placeholder => '#',
              :if => 'renovationsRoof.yes',
            },
            {
              :name => '',
              :id => 'renovationsRoofCompletePartial',
              :type => 'radio',
              :options => {
                'complete' => 'Complete',
                'partial' => 'Partial',
              },
              :if => 'renovationsRoof.yes',
            },
            {
              :name => 'Nearest Fire Hydrant',
              :id => 'fireHydrants',
              :type => 'dropdown',
              :placeholder => 'Select distance',
              :options => [
                'Unprotected',
                'Within 150m',
                'Within 300m',
                'Over 300m',
              ],
            },
            {
              :name => 'Nearest Fire Department',
              :id => 'fireDepartment',
              :type => 'dropdown',
              :placeholder => 'Select distance',
              :options => [
                'Not Specified',
                'Within 5km',
                'Within 8km',
                'Within 13km',
                'Over 13km',
              ],
            },
            {
              :name => 'Extinguishing System',
              :id => 'extinguishingSystem',
              :type => 'dropdown',
              :placeholder => 'Select a type..',
              :options => [
                'Portable Extinguishing(s)',
                'Sprinkler',
                'None',
                'Other',
              ],
            },
            {
              :name => 'Extinguishing Agent',
              :id => 'extinguishingAgent',
              :type => 'radio',
              :placeholder => 'Select a type...',
              :options => {
                'water' => 'Water',
                'chemical' => 'Chemical',
                'carbonDioxide' => 'Carbon Dioxide (CO2)',
                'foam' => 'Foam',
                'halon' => 'Halon',
                'dryChemical' => 'Dry Chemical',
                'automaticCO2' => 'Automatic CO2',
              },
            },
            {
              :name => 'Fire Alarm',
              :id => 'fireAlarm',
              :type => 'dropdown',
              :placeholder => 'Select a type..',
              :options => [
                'None',
                'Complete',
                'Central Station',
                'Monitoring Station (Full)',
                'Monitoring Station (Shared)',
                'Local Alarm',
                'Other',
              ],
            },
            {
              :name => 'Coverage %',
              :id => 'coveragePercent',
              :placeholder => '%',
              :type => 'text',
            },
            {
              :id => 'standpipe',
              :type => 'checkbox',
              :options => {
                'yes' => 'Standpipe & Hose',
              },
            },
            {
              :name => 'Other Info',
              :id => 'otherFireInfo',
              :type => 'textbox',
            },
            {
              :name => 'Crime Protection Types',
              :id => 'protectionTypes',
              :type => 'checkbox',
              :options => {
                'deadbolt' => 'Doors – deadbolt',
                'breakageResistantGlass' => 'Breakage resistant glass',
                'windowsBarred' => 'Windows - barred',
                'windowsWireMesh' => 'Windows – wire mesh',
                'steelBars' => 'Steel bars on openings',
                'cameras' => 'Surveillance cameras ',
                'watchmen' => 'Watchmen/security guards',
                'fence' => 'Fence',
                'guardDog' => 'Guard Dog',
                'windowsULC' => 'Windows – ULC security film',
                'comboLock' => 'Additional combination lock',
                'additionalKey' => 'Additional key',
                'fineWireProtection' => 'Alarm "fine wire" protecting openings',
                'concealed' => 'Camera with concealed VCR recording on film',
                'commonWalls' => 'Common tenant walls reinforced with steel mesh',
                'electronicLock' => 'Electronic lock',
                'visibleEntrance' => 'Entrance visible from street',
                'sturdyDoors' => 'Exterior doors of sturdy construction, inside hinges',
                'extLighting' => 'Exterior lighting',
                'holdupButtons' => 'Hold-up buttons',
                'metalDoors' => 'Metal loading doors, secured internally',
                'motionLighting' => 'Motion sensitive lighting',
                'multipleLocks' => 'Multiple lock styles',
                'perimeter' => 'Perimeter fence and lockable gate',
                'nightIllumination' => 'Property/lot illuminated at night',
                'blockedSkylight' => 'Skylight/Roof AC openings blocked off',
                'steelPost' => 'Steel post (front & rear) to prevent vehicle entry',
                'stockSecured' => 'Stock secured – separate enclosure',
                'stockroomMotion' => 'Stockroom ceiling entirely covered by motion sensor',
                'warehouseAlarm' => 'Warehouse area alarmed separately from office',
                'warningSigns' => 'Warning signs',
                'glassBreakageDetect' => 'Windows – Glass breakage detectors',
                'other' => 'Other (describe)',
              },
            },
            {
              :name => 'Describe if other',
              :id => 'protectionTypesOther',
              :type => 'text',
              :if => 'protectionTypes.other'
            },
            {
              :name => 'Burglar Alarm',
              :id => 'burglarAlarm',
              :type => 'dropdown',
              :placeholder => 'Select a type..',
              :options => [
                'None',
                'Complete',
                'Partial',
                'Central Station',
                'Monitoring Station (Full)',
                'Monitoring Station (Partial)',
                'Local',
                'Other',
              ],
            },
            {
              :name => 'Safe Type',
              :id => 'safeType',
              :type => 'radio',
              :options => {
                'fire' => 'Fire',
                'burglary' => 'Burglary',
                'vault' => 'Vault',
                'none' => 'None',
              },
            },
            {
              :name => 'Safe Class',
              :id => 'safeClass',
              :type => 'dropdown',
              :options => [
                '1',
                '2',
                '3',
                '4',
                '5',
                'Other'
              ],
            },
            {
              :name => 'Other',
              :id => 'crimeProtectionOther',
              :placeholder => 'Other Useful Info',
              :type => 'textbox',
            },
            {
              :name => 'Occupancy Insured',
              :id => 'occupancyInsured',
              :placeholder => 'Description',
              :type => 'textbox',
            },
            {
              :name => 'Occupancy Others',
              :id => 'occupancyOthers',
              :placeholder => 'Description',
              :type => 'textbox',
            },
            {
              :name => 'Exposures',
              :id => 'exposuresClear',
              :type => 'checkbox',
              :options => {
                'yes' => 'Clear in all directions',
              },
            },
            {
              :name => 'Left of Insured',
              :id => 'exposuresLeft',
              :placeholder => 'Description (ex. clear)',
              :type => 'textbox',
              :if => '!exposuresClear.yes',
            },
            {
              :name => 'Right of Insured',
              :id => 'exposuresRight',
              :placeholder => 'Description (ex. clear)',
              :type => 'textbox',
              :if => '!exposuresClear.yes',
            },
            {
              :name => 'Behind Insured',
              :id => 'exposuresBehind',
              :placeholder => 'Description (ex. clear)',
              :type => 'textbox',
              :if => '!exposuresClear.yes',
            },
            # Not in Marc's template
            # {
            #   :name => 'Loss Payees',
            #   :id => 'lossPayees',
            #   :placeholder => 'Firstname Lastname',
            #   :type => 'textbox',
            # },
            # {
            #   :name => '',
            #   :id => 'lossPayeesType',
            #   :type => 'radio',
            #   :options => {
            #     'mortgage' => '(as per standard mortgage clause)',
            #     'interests' => '(as their interests may appear)',
            #   }
            # },
          ],
        },
        {
          :name => 'Buildings',
          :id => 'buildings',
          :type => [
            {
              :name => 'Building #',
              :id => 'buildingNumber',
              :type => 'text',
              :placeholder => '#',
              :required => true,
            },
            {
              :name => 'Address',
              :id => 'address',
              :type => 'text',
              :placeholder => 'Address (apt., suite, bldg.)',
              :prefill => {
                :auto => 'Same as Location',
              },
            },
            {
              :name => 'Description',
              :id => 'description',
              :type => 'text',
              :placeholder => 'Description',
            },
            {
              :name => 'Coinsurance',
              :id => 'coinsurance',
              :type => 'text',
              :placeholder => 'ex. 90%',
              :prefill => {
                :auto => '90%',
              },
              :if => '!statedAmount.yes',
            },
            {
              :name => '',
              :id => 'statedAmount',
              :type => 'checkbox',
              :options => {
                'yes' => 'Stated Amount',
              }
            },
            {
              :name => 'Replacement Cost',
              :id => 'replacementCost',
              :type => 'currency',
              :placeholder => '$ CAN (ex. 111.11)',
            },
            {
              :name => 'Actual Cash Value',
              :id => 'actualCashValue',
              :type => 'currency',
              :placeholder => '$ CAN (ex. 111.11)',
            },
            {
              :name => 'Rate',
              :id => 'rate',
              :type => 'currency',
              :placeholder => '$ CAN (ex. 111.11)',
            },
            {
              :name => 'Premium',
              :id => 'premium',
              :type => 'currency',
              :placeholder => '$ CAN (ex. 111.11), calculated from rate and replacement cost',
              :prefill => {
                :calc => 'buildings.rate.value*(buildings.replacementCost.value || buildings.actualCashValue.value)/1000',
              },
            },
          ],
        },
        {
          :name => 'Coverage Sched.',
          :id => 'coverageSchedules',
          :partial => 'templates/clients/sections/coverage_schedules',
          :type => [
            # Primary field only, for the table. The rest are declared in the partia
            {
              :name => 'Type',
              :id => 'type',
              :required => true,
              :type => 'text',
            },
            {
              :id => 'category',
              :required => true,
              :type => 'text',
            },
            {
              :id => 'options',
              :type => 'radio',
              :options => {
                'building' => 'Building',
                'equipment' => 'Equipment',
                'stock' => 'Stock',
              }
            },
            {
              :id => 'subtype',
              :type => 'radio',
              :options => {
                'broad' => 'Broad',
                'named' => 'Named',
                'nameOfEmployee' => 'Name',
                'position' => 'Position',
                'robbery' => 'Robbery',
                'fourPoint' => '4 Point',
                'sevenPoint' => '7 Point',
                'limited' => 'Limited',
                'profit' => 'Profit',
                'nonProfit' => 'Non-Profit',
              }
            },
            {
              :id => 'replacementCost',
              :type => 'currency'
            },
            {
              :id => 'deductible',
              :type => 'currency'
            },
            {
              :id => 'coinsurance',
              :type => 'text'
            },
            {
              :id => 'limit',
              :type => 'currency'
            },
          ],
        },
        {
          :name => 'Auto Schedule',
          :id => 'autoSchedules',
          :type => [
            {
              :name => 'Item #',
              :id => 'itemNumber',
              :required => true,
              :placeholder => '# ( ex. 1111)',
              :type => 'text',
            },
            {
              :name => 'Unit #',
              :id => 'unitNumber',
              :placeholder => '# ( ex. 1111)',
              :type => 'text',
            },
            {
              :name => 'Owner',
              :id => 'owner',
              :type => 'dropdown',
              :placeholder => '',
              :options => [
                'Company',
                'Contractor',
                'Owner-operator',
                'Other',
              ],
            },
            {
              :name => 'Finance Company',
              :id => 'financeCompany',
              :placeholder => 'Some Truck Co.',
              :type => 'text',
            },
            {
              :name => 'Year',
              :id => 'year',
              :placeholder => '#',
              :type => 'text',
            },
            {
              :name => 'Make',
              :id => 'make',
              :placeholder => '(ex. Ford)',
              :type => 'text',
            },
            {
              :name => 'Model',
              :id => 'model',
              :placeholder => '(ex. F250 Super Duty XL)',
              :type => 'text',
            },
            {
              :name => 'Serial Number',
              :id => 'serialNumber',
              :placeholder => '(ex. 1FTFE1160WHA00001)',
              :type => 'text',
            },
            {
              :name => 'Plate #',
              :id => 'plateNumber',
              :placeholder => 'license plate # (ex. 111 111)',
              :type => 'text',
            },
            {
              :name => 'Colour',
              :id => 'colour',
              :placeholder => '(ex. blue)',
              :type => 'text',
            },
            {
              :name => 'Lessor',
              :id => 'lessor',
              :placeholder => '(ex. Owned)',
              :type => 'text',
            },
            {
              :name => 'Date Added',
              :id => 'dateAdded',
              :type => 'date',
            },
            {
              :name => 'Policy Expiry',
              :id => 'policyExpiry',
              :type => 'date',
            },
            {
              :name => 'Deleted',
              :id => 'deleted',
              :type => 'date',
            },
            {
              :name => 'Premium',
              :id => 'premium',
              :placeholder => '$ CAN (ex. 111.11)',
              :type => 'currency',
            },
            {
              :name => 'Premium Credit',
              :id => 'premiumCredit',
              :placeholder => '$ CAN (ex. 111.11)',
              :type => 'currency',
            },
            {
              :name => 'Cargo',
              :id => 'cargo',
              :placeholder => '$ CAN (ex. 111.11)',
              :type => 'currency',
            },
            {
              :name => 'Cargo Credit',
              :id => 'cargoCredit',
              :placeholder => '$ CAN (ex. 111.11)',
              :type => 'currency',
            },
          ],
        },
        {
          :name => 'Equip. Schedule',
          :id => 'equipmentSchedules',
          :type => [
            {
              :name => 'Type',
              :id => 'type',
              :type => 'dropdown',
              :required => true,
              :placeholder => 'Select a type..',
              :options => [
                'Contractors Equipment',
                'Motor Truck Cargo',
                'Miscellaneous Property',
                'Fine Arts',
                'Other',
              ]
            },
            {
              :name => 'Item #',
              :id => 'itemNumber',
              :type => 'text',
              :placeholder => '#',
              :required => true,
            },
            {
              :name => 'Year',
              :id => 'year',
              :type => 'number',
              :placeholder => 'yyyy',
            },
            {
              :name => 'Make',
              :id => 'make',
              :type => 'text',
              :placeholder => 'Manufacturer',
            },
            {
              :name => 'Model',
              :id => 'model',
              :type => 'text',
              :placeholder => 'Model',
            },
            {
              :name => 'Serial Number',
              :id => 'serialNumber',
              :type => 'text',
              :placeholder => 'ex. A1234567890',
            },
            {
              :name => 'Lessor',
              :id => 'lessor',
              :type => 'text',
              :placeholder => 'Lessor',
            },
            {
              :name => 'Description',
              :id => 'description',
              :type => 'text',
              :placeholder => 'Describe the item',
            },
            {
              :name => 'Limit',
              :id => 'limit',
              :type => 'text',
              :placeholder => '',
            },
          ]
        },
        {
          :name => 'Misc. Schedule',
          :id => 'miscellaneousSchedules',
          :type => [
            {
              :name => 'Type',
              :id => 'type',
              :type => 'dropdown',
              :required => true,
              :placeholder => 'Select a type..',
              :options => [
                'Contractors Equipment',
                'Motor Truck Cargo',
                'Miscellaneous Property',
                'Fine Arts',
                'Other',
              ]
            },
            {
              :name => 'Item #',
              :id => 'itemNumber',
              :type => 'text',
              :placeholder => '#',
              :required => true,
            },
            {
              :name => 'Year',
              :id => 'year',
              :type => 'number',
              :placeholder => 'yyyy',
            },
            {
              :name => 'Make',
              :id => 'make',
              :type => 'text',
              :placeholder => 'Manufacturer',
            },
            {
              :name => 'Model',
              :id => 'model',
              :type => 'text',
              :placeholder => 'Model',
            },
            {
              :name => 'Serial Number',
              :id => 'serialNumber',
              :type => 'text',
              :placeholder => 'ex. A1234567890',
            },
            {
              :name => 'Lessor',
              :id => 'lessor',
              :type => 'text',
              :placeholder => 'Lessor',
            },
            {
              :name => 'Description',
              :id => 'description',
              :type => 'text',
              :placeholder => 'Describe the item',
            },
            {
              :name => 'Limit',
              :id => 'limit',
              :type => 'text',
              :placeholder => '',
            },
          ]
        },
        {
          :name => 'Drivers',
          :id => 'drivers',
          :type => [
            {
              :name => 'Driver #',
              :id => 'driver',
              :type => 'text',
              :placeholder => '#',
            },
            {
              :name => 'Name',
              :id => 'name',
              :type => 'text',
              :placeholder => 'Firstname Lastname',
            },
            {
              :name => 'License #',
              :id => 'licenseNumber',
              :type => 'text',
              :placeholder => 'ex. S3372-17979-01010'
            },
            {
              :name => 'Date Employed',
              :id => 'dateEmployed',
              :type => 'date',
            },
            {
              :name => 'Accidents',
              :id => 'accidents',
              :type => 'text',
              :placeholder => 'Number of accidents and type',
            },
            {
              :name => 'Convictions',
              :id => 'convictions',
              :type => 'text',
              :placeholder => 'Number of convictions and type',
            },
          ]
        },
        {
          :name => 'Loss Control Survey',
          :id => 'lossControlSurvey',
          :type => [
            {
              :name => 'Performed by',
              :id => 'surveyPerformedBy',
              :placeholder => 'Name',
              :type => 'text',
            },
            {
              :name => 'Performed on',
              :id => 'surveyDate',
              :type => 'date',
            },
            {
              :name => 'Person interviewed',
              :id => 'surveyInterviewee',
              :placeholder => 'Name',
              :type => 'text',
            },
            {
              :id => 'surveyHeatingServiced',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Has heating / cooling systems been serviced in past 12 months?'
              }
            },
            {
              :id => 'surveyCombClearance',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Is there adequate clearance to combustibles?'
              }
            },
            {
              :id => 'surveyTemporaryHeating',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Any use of temporary heating device(s)?'
              }
            },
            {
              :id => 'surveyElectricalUpgrades',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Any electrical upgrades that we should be aware of?'
              }
            },
            {
              :id => 'surveyElectricalUpgradesComment',
              :name => 'Describe',
              :type => 'text',
              :if => 'surveyElectricalUpgrades.yes'
            },
            {
              :id => 'surveyExtensionCords',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Any extension cords in use?'
              }
            },
            {
              :id => 'surveyService',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Size of Service and on breakers?'
              }
            },
            {
              :id => 'surveyServiceComment',
              :name => 'Describe',
              :type => 'text',
              :if => 'surveyService.yes'
            },
            {
              :id => 'surveyWiring',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Wiring supported and in good condition?'
              }
            },
            {
              :id => 'surveyThermScan',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Has thermo-graphic scan been performed?'
              }
            },
            {
              :id => 'surveyAislesClear',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Aisles free and clear of obstructions?'
              }
            },
            {
              :id => 'surveyStockRooms',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Stock rooms organized and well lit?'
              }
            },
            {
              :id => 'surveyCrossDoc',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Cross dock clear and safe?'
              }
            },
            {
              :id => 'surveyTrashClear',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Trash and pallets clear from building 50\'?'
              }
            },
            {
              :id => 'surveyWellLit',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Well lit retail / traffic area free of trip hazards?'
              }
            },
            {
              :id => 'surveyDispensing',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Dispensing operations and related safety precautions?'
              }
            },
            {
              :id => 'surveyDispensingComment',
              :name => 'Describe',
              :type => 'text',
              :if => 'surveyDispensing.yes'
            },
            {
              :id => 'surveySolventStorage',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Are proper storage of solvents and flammables present?'
              }
            },
            {
              :id => 'surveyRefueling',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Are there any refueling tanks on site?'
              }
            },
            {
              :id => 'surveyRefuelingComment',
              :name => 'Describe',
              :type => 'text',
              :if => 'surveyRefueling.yes'
            },
            {
              :id => 'surveyDisasterPlan',
              :name => '',
              :type => 'checkbox',
              :if => 'surveyRefueling.yes',
              :options => {
                'yes' => 'If there is refueling on site, is there a disaster plan?'
              }
            },
            {
              :id => 'surveyFireHall',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Distance to Fire Hall and type of fire hall?'
              }
            },
            {
              :id => 'surveyFireHallComment',
              :name => 'Distance and Type',
              :type => 'text',
              :if => 'surveyFireHall.yes'
            },
            {
              :id => 'surveyFireExtinguishers',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Are there fire extinguishers present?'
              }
            },
            {
              :id => 'surveyFireExtinguishersComment',
              :name => 'Size and type',
              :type => 'text',
              :if => 'surveyFireExtinguishers.yes'
            },
            {
              :id => 'surveyExtinguishersServiced',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Fire extinguishers serviced in last 12 months?'
              }
            },
            {
              :id => 'surveyExtinguishersServicedComment',
              :name => 'By whom?',
              :type => 'text',
              :if => 'surveyExtinguishersServiced.yes'
            },
            {
              :id => 'surveyAlarmPanel',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Fire alarm panel free of trouble signs?'
              }
            },
            {
              :id => 'surveyAutomaticSprinkler',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Is there an automatic sprinkler?'
              }
            },
            {
              :id => 'surveyAutomaticSprinklerComment',
              :name => 'History of Testing',
              :type => 'text',
              :if => 'surveyAutomaticSprinkler.yes'
            },
            {
              :id => 'surveyStandpipe',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Standpipe and hose tested and inspected last 12 months?'
              }
            },
            {
              :id => 'surveyPerimeter',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Is there any perimeter fencing?'
              }
            },
            {
              :id => 'surveyPerimeterComment',
              :name => 'Fenced %',
              :type => 'text',
              :if => 'surveyPerimeter.yes'
            },
            {
              :id => 'surveyExteriorLighting',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Is exterior lighting adequate present and working?'
              }
            },
            {
              :id => 'surveyObstructions',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Access points free of obstructions?'
              }
            },
            {
              :id => 'surveyAdequateExposure',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Are doors, windows and locks adequate for exposure?'
              }
            },
            {
              :id => 'surveyBurglarResistant',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Is there burglar resistant glass and or window (door) bars present?'
              }
            },
            {
              :id => 'surveyULCEquipment',
              :name => 'ULC equipment',
              :type => 'textbox',
            },
            {
              :id => 'surveyAlarmCompany',
              :name => 'Alarm company',
              :type => 'text',
              :placeholder => 'Name and address',
            },
            {
              :id => 'surveyHeatMotion',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Does alarm system include heat, motion and smoke?'
              }
            },
            {
              :id => 'surveySnowRemoval',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Do you hire snow removal?'
              }
            },
            {
              :id => 'surveyCertificates',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Do you gather certificates of insurance from any contractor that is doing work on your premises?'
              }
            },
            {
              :id => 'surveyCertificateFile',
              :name => 'How long do you keep those certificates on file?',
              :type => 'text',
              :if => 'surveyCertificates.yes',
            },
            {
              :id => 'surveyCertificateCopy',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Could we have a copy of the certificate that your broker created for you?'
              },
              :if => 'surveyCertificates.yes',
            },
            {
              :id => 'surveySlipAndFall',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Do you have a slip and fall policy?'
              }
            },
            {
              :id => 'surveyDisasterPlan',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'May we see a copy of your disaster plan that your broker / agent helped you to prepare?'
              }
            },
            {
              :id => 'surveyFireDoors',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Are all fire doors free and clear of obstructions?'
              }
            },
            {
              :id => 'surveyFireExits',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Are all fire exits properly identified?'
              }
            },
            {
              :id => 'surveyFireExitsOperable',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Are all fire exit doors operable (not chained or locked)?'
              }
            },
            {
              :id => 'surveyTrained',
              :name => '',
              :type => 'checkbox',
              :options => {
                'yes' => 'Are all employees trained in emergency evacuation procedures?'
              }
            },
            {
              :name => 'Other/Notes',
              :id => 'surveyOther',
              :placeholder => 'Notes',
              :type => 'textbox'
            },
          ]
        },
        {
          :name => 'Photos',
          :id => 'photos',
          :type => [
            {
              :name => 'Notes',
              :id => 'photoNotes',
              :placeholder => 'Take a note',
              :type => 'text',
            },
            {
              :name => 'Organize Photos By',
              :id => 'organizePhotos',
              :type => 'dropdown',
              :placeholder => 'Date',
              :options => [
                'Alphabetically',
                'Date',
                'Photographer',
              ],
            },
          ],
        },
      ],
    },
    {
      :name => 'Misc. Notes',
      :id => 'miscNote',
      :type => [
        {
          :name => 'Notes',
          :id => 'notes',
          :placeholder => 'Other Useful Info',
          :type => 'textbox',
        },
      ],
    },
    {
      :name => 'Declaration',
      :id => 'Declaration',
      :type => [
        {
          :name => 'I have known this client since',
          :id => 'dateKnown',
          :type => 'date',
        },
        {
          :name => '',
          :id => 'newClient',
          :type => 'checkbox',
          :options => {
            'yes' => 'This client is new to my office.',
          },
        },
      ],
    }
  ]

  def self.expand_fields(node = FIELDS)
    fields = node.map do |field|
      if field[:type].is_a?(Array) && !field[:id].ends_with?('s')
        field[:type]
      else
        field
      end
    end
    return fields.flatten
  end

  def validate_value(field_name, field_desc, value)
    if value.nil? || value == ''
      if field_desc[:required]
        errors[field_name] << 'is required'
      end
    else
      case field_desc[:type]
      when 'text'
        value = value.to_s
        if field_desc[:maxlength] && value.length > field_desc[:maxlength]
          errors[field_name] << 'is too long'
        end
        if field_desc[:minlength] && value.length < field_desc[:minlength]
          errors[field_name] << 'is too short'
        end
      when 'number'
        begin
          value = Integer(value)
        rescue
          errors[field_name] << 'must be an integer'
          return nil
        end
      when 'phone'
        value = value.to_s
        if !(/^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/i.match(value))
          errors[field_name] << 'not valid phone number'
        end
      when 'email'
        value = value.to_s
        if !( /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i.match(value))
          errors[field_name] << 'not valid email'
        end
      when 'currency'
        value = value.to_s
        if !(/^\d+(\.\d{0,2})?/i.match(value))
          errors[field_name] << 'not valid currency format'
        end
      when 'radio', 'dropdown'
        # Has to be one of the given values
        if !field_desc[:options].include?(value) && !field_desc[:options].include?('Other')
          errors[field_name] << 'is not one of the provided options'
        end
      when 'checkbox'
        # Each value has to be true/false
        if !value.nil?
          if value.is_a? Hash
            value.each do |key, val|
              value[key] = (val == true || val =~ /^(true|t|yes|on|y|1)$/i)
            end
          else
            errors[field_name] << 'must be a checkbox value'
          end
        end
      end
    end
    return value
  end

  def validate_field(obj, field, parent = nil)
    field_name = field[:id].underscore.humanize + (parent ? ' in ' + parent[:id].underscore.humanize.downcase : '')
    val = obj[field[:id]]
    if val.nil?
      if field[:required]
        errors[field_name] << 'is required'
      end
    elsif val['updated_at'].nil? && parent.nil? # TODO: for now, let's just ignore it on subfields
      errors[field_name] << 'must contain "updated_at"'
    elsif val['value'].nil?
      if field[:type].is_a?(Array)
        # Rails parses empty arrays as nil. Assume that's what happened
        val['value'] = []
      else
        errors[field_name] << 'must contain "value"'
      end
    elsif field[:type].is_a?(Array)
      if !val['value'].is_a?(Array)
        errors[field_name] << 'must be an array'
      else
        val['value'].each_with_index do |subval, i|
          field[:type].each do |subfield|
            validate_field(subval, subfield, field)
          end
        end
      end
    else
      value = validate_value(field_name, field, val['value'])
      val['value'] = value unless value.nil?
    end
  end

  def valid?(context = nil)
    errors.clear

    # Custom validation.
    Client.expand_fields.each do |field|
      validate_field(self, field)
    end

    errors.empty? && super(context)
  end
end
