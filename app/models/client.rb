require 'consilium_fields'

class Client
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Mongoid::Paranoia
  include ConsiliumFields

  belongs_to :brokerage

  has_many :client_changes, dependent: :delete
  has_many :documents, dependent: :delete
  has_many :user_permissions, dependent: :delete

  field :editing_time, type: Integer, default: 0

  FIELDS = [
    {
      :name => 'Basic Client Info',
      :id => 'basicClientInfo',
      :class => 'startOpen',
      :type => [
        {
          :name => 'Company',
          :id => 'company',
          :placeholder => 'Name of Company',
          :type => 'text',
          :required => true,
          :primary => true,
        },
        {
          :name => 'Name',
          :id => 'name',
          :placeholder => 'Firstname Lastname',
          :type => 'text',
          :required => true,
          :primary => true,
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
          :name => 'Application Type',
          :id => 'type',
          :type => 'dropdown',
          :placeholder => 'Generic',
          :options => [
            'Solar',
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
          :name => 'Province/State',
          :id => 'province',
          :type => 'dropdown',
          :options => [
            'Alberta',
            'British Columbia',
            'Manitoba',
            'New Brunswick', 'Newfoundland and Labrador', 'Northwest Territories',
            'Nova Scotia',
            'Nunavut', 'Ontario',
            'Prince Edward Island',
            'Quebec',
            'Saskatchewan',
            'Yukon Territory',
            'Other',
          ],
        },
        {
          :name => 'Country',
          :id => 'country',
          :placeholder => '',
          :type => 'dropdown',
          :options => [
            'Canada',
            'Other',
          ]
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
      ],
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
          :primary => true,
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
          :intelligent => true,
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
          :primary => true,
        },
        {
          :name => 'Type of Claim',
          :id => 'claimType',
          :placeholder => '(ex. Commercial)',
          :type => 'text',
          :intelligent => true,
          :primary => true,
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
      :name => 'Policy Info',
      :id => 'policyInfos',
      :type => [
        {
          :name => 'Insurer',
          :id => 'prevInsurer',
          :required => true,
          :placeholder => 'Name',
          :type => 'text',
          :intelligent => true,
          :primary => true,
        },
        {
          :name => 'Policy Type',
          :id => 'prevPolicyType',
          :required => true,
          :type => 'dropdown',
          :options => [
            'CGL',
            'CMP',
            'IRCA',
            'Fleet',
            'Environmental',
            'WSIB Alternative',
            'Other',
          ],
          :primary => true,
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
          :name => 'Inception Date',
          :id => 'prevTermStart',
          :type => 'date',
        },
        {
          :name => 'Expiry Date',
          :id => 'prevTermEnd',
          :type => 'date',
          :prefill => {
            :type => 'watch',
            :watch => 'policyInfos.prevTermStart.value',
            :expr => 'policyInfos.prevTermStart.value + ' + 1.years.to_s,
          },
        },
        {
          :name => 'Quote Required By',
          :id => 'quoteRequiredBy',
          :type => 'date',
        },
      ],
    },
    {
      :name => 'Prev. Policy Info',
      :id => 'prevPolicyInfos',
      :type => [
        {
          :name => 'Insurer',
          :id => 'prevInsurer',
          :required => true,
          :placeholder => 'Name',
          :type => 'text',
          :intelligent => true,
          :primary => true,
        },
        {
          :name => 'Policy Type',
          :id => 'prevPolicyType',
          :required => true,
          :type => 'dropdown',
          :options => [
            'CGL',
            'CMP',
            'IRCA',
            'Fleet',
            'Environmental',
            'WSIB Alternative',
            'Other',
          ],
          :primary => true,
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
          :name => 'Inception Date',
          :id => 'prevTermStart',
          :type => 'date',
        },
        {
          :name => 'Expiry Date',
          :id => 'prevTermEnd',
          :type => 'date',
          :prefill => {
            :type => 'watch',
            :watch => 'prevPolicyInfos.prevTermStart.value',
            :expr => 'prevPolicyInfos.prevTermStart.value + ' + 1.years.to_s,
          },
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
          :type => 'separator',
          :clientType => 'solar',
        },
        {
          :name => 'Annual energy generation',
          :id => 'solarAnnualEnergy',
          :type => 'text',
          :clientType => 'solar',
          :placeholder => 'Annual energy generation by location (kWh)'
        },
        {
          :name => 'Energy sold to',
          :id => 'solarEnergySoldTo',
          :type => 'checkbox',
          :clientType => 'solar',
          :options => {
            'utility' => 'Utility',
            'host' => 'Host',
            'other' => 'Other',
          }
        },
        {
          :name => 'Describe',
          :id => 'solarEnergySoldToOther',
          :type => 'text',
          :clientType => 'solar',
          :placeholder => 'Describe other',
          :if => 'solarAnnualEnergy.other',
        },
        {
          :name => 'Utility',
          :id => 'solarUtility',
          :type => 'text',
          :clientType => 'solar',
          :placeholder => 'Name of utility/local distribution company'
        },
        {
          :name => 'Host',
          :id => 'solarHost',
          :type => 'text',
          :clientType => 'solar',
          :placeholder => 'Name of owner of leased site location (host)',
        },
        {
          :name => 'Lessor',
          :id => 'solarLessor',
          :type => 'text',
          :clientType => 'solar',
          :placeholder => 'Name of lessor of leased equipment',
        },
        {
          :name => '',
          :id => 'solarProjectRestricted',
          :type => 'checkbox',
          :clientType => 'solar',
          :options => {
            'yes' => 'Is project access restricted?'
          }
        },
        {
          :name => 'Describe',
          :id => 'solarProjectRestrictedDescribe',
          :type => 'text',
          :clientType => 'solar',
          :placeholder => 'If restricted, describe',
          :if => 'solarProjectRestricted.yes'
        },
        {
          :name => '',
          :id => 'solarTransmission',
          :type => 'checkbox',
          :clientType => 'solar',
          :options => {
            'yes' => 'Do you own or maintain any electric transmission distribution lines or substations?'
          }
        },
        {
          :name => 'Describe',
          :id => 'solarTransmissionDescribe',
          :type => 'text',
          :clientType => 'solar',
          :placeholder => 'If yes, describe line length (km) and number of substations',
          :if => 'solarTransmission.yes'
        },
        {
          :type => 'separator',
          :clientType => 'solar',
        },
        {
          :name => 'Non-workers\' compensation',
          :id => 'solarNonWorkersCompensation',
          :type => 'text',
          :clientType => 'solar',
          :placeholder => 'Number of employees not covered by workers compensation',
        },
        {
          :name => 'Non-covered employee class',
          :id => 'solarNonWorkersCompensationClass',
          :type => 'dropdown',
          :clientType => 'solar',
          :if => 'solarNonWorkersCompensation > 0',
          :options => [
            'Office',
            'Other',
          ]
        },
        {
          :type => 'separator',
          :clientType => 'solar',
        },
        {
          :name => 'Sub-contracts',
          :id => 'solarSubcontracts',
          :type => 'text',
          :clientType => 'solar',
          :placeholder => 'If any work is subcontracted, describe type of work contracted',
        },
        {
          :name => '',
          :id => 'solarSubcontractorCoverage',
          :type => 'checkbox',
          :clientType => 'solar',
          :options => {
            'yes' => 'Subcontractor coverage required',
          }
        },
        {
          :name => 'Limit required',
          :id => 'solarSubcontractorCoverageLimit',
          :type => 'text',
          :clientType => 'solar',
          :placeholder => 'Limit required for subcontractors',
          :if => 'solarSubcontractorCoverage.yes'
        },
        {
          :name => '',
          :id => 'solarSubcontractorCoverageAdditionalInsured',
          :type => 'checkbox',
          :clientType => 'solar',
          :options => {
            'yes' => 'Are you named as an additional insured?',
          },
          :if => 'solarSubcontractorCoverage.yes'
        },
        {
          :name => '',
          :id => 'solarSubcontractorCoverageWaive',
          :type => 'checkbox',
          :clientType => 'solar',
          :options => {
            'yes' => 'Do you waive your rights of subrogation?',
          },
          :if => 'solarSubcontractorCoverage.yes'
        },
        {
          :name => '',
          :id => 'solarSubcontractorCoverageCertificates',
          :type => 'checkbox',
          :clientType => 'solar',
          :options => {
            'yes' => 'Are certificates of insurance required for all subcontractors?',
          },
          :if => 'solarSubcontractorCoverage.yes'
        },
        {
          :type => 'separator',
          :clientType => 'solar',
        },
        {
          :name => '',
          :id => 'solarSubcontractorCoveragePlannedSites',
          :type => 'checkbox',
          :clientType => 'solar',
          :options => {
            'yes' => 'Are any site(s) planned or in the process of construction?'
          }
        },
        {
          :name => 'Describe',
          :id => 'solarSubcontractorCoveragePlannedDescribe',
          :type => 'text',
          :clientType => 'solar',
          :placeholder => 'If yes, describe',
          :if => 'solarSubcontractorCoveragePlannedSites.yes'
        },
        {
          :type => 'separator',
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
          :required => true,
          :type => 'text',
          :placeholder => 'Operation or product type',
          :intelligent => true,
          :primary => true,
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
      :name => 'Locations',
      :id => 'locations',
      :buttonTitle => 'Create Location',
      :editHref => '#/clients/edit/{{clientId}}/location/{{$index}}{{ clientChangeId && "?change=" + clientChangeId }}',
      :createHref => '#/clients/edit/{{client.id}}/location/',
      :type => [
        {
          :name => 'Basic Location Info',
          :id => 'basicLocationInfo',
          :class => 'startOpen',
          :type => [
            {
              :name => 'Location Number',
              :id => 'locationNumber',
              :placeholder => '# (ex. 1111)',
              :type => 'text',
              # This is sequenced in the controller.
              :required => true,
              :primary => true,
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
              :primary => true,
            },
            {
              :name => 'City',
              :id => 'locationCity',
              :placeholder => 'City',
              :type => 'text',
            },
            {
              :name => 'Country',
              :id => 'country',
              :type => 'dropdown',
              :options => [
                'Canada',
                'Other',
              ],
            },
            {
              :name => 'Province/State',
              :id => 'province',
              :type => 'dropdown',
              :options => [
                'Alberta',
                'British Columbia',
                'Manitoba',
                'New Brunswick', 'Newfoundland and Labrador', 'Northwest Territories',
                'Nova Scotia',
                'Nunavut', 'Ontario',
                'Prince Edward Island',
                'Quebec',
                'Saskatchewan',
                'Yukon Territory'
              ],
            },
            {
              :name => 'Postal Code',
              :id => 'locationPostalCode',
              :placeholder => '(ex. A1A 1A1)',
              :type => 'text',
            },
          ],
        },
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
              :clientType => '',
            },
            {
              :name => 'Type of project',
              :id => 'solarProjectType',
              :type => 'dropdown',
              :clientType => 'solar',
              :options => [
                'Photovoltaic (PV)',
                'Concentrating Solar Power (CSP)',
                'Other'
              ]
            },
            {
              :name => 'Type of solar PV mounting',
              :id => 'pvMountingType',
              :type => 'radio',
              :clientType => 'solar',
              :options => {
                'rooftop' => 'Rooftop',
                'ground' => 'Ground',
              },
              :if => 'solarProjectType == "Photovoltaic (PV)"'
            },
            {
              :name => 'Mounting structure/device',
              :id => 'solarMountingStructure',
              :type => 'dropdown',
              :clientType => 'solar',
              :options => [
                'Non-combustible',
                'Combustible',
                'Sun-tracker',
                'Stationary',
              ]
            },
            {
              :type => 'heading',
              :clientType => 'solar',
              :text => 'Roof-top Mounted',
              :if => 'pvMountingType == "rooftop"',
            },
            {
              :name => 'Type and use of attached structure',
              :id => 'solarStructureType',
              :type => 'text',
              :clientType => 'solar',
              :if => 'pvMountingType == "rooftop"',
            },
            {
              :name => 'Location operation',
              :id => 'solarLocationOperation',
              :type => 'radio',
              :clientType => 'solar',
              :options => {
                'yearRound' => 'Year Round',
                'seasonal' => 'Seasonal',
              },
              :if => 'pvMountingType == "rooftop"',
            },
            {
              :name => '',
              :id => 'solarRoofLeased',
              :type => 'checkbox',
              :clientType => 'solar',
              :options => {
                'yes' => 'Is the roof leased?',
              },
              :if => 'pvMountingType == "rooftop"',
            },
            {
              :name => '',
              :id => 'solarEngineeringEvaluation',
              :type => 'checkbox',
              :clientType => 'solar',
              :options => {
                'yes' => 'Structural engineering evaluation completed?',
              },
              :if => 'pvMountingType == "rooftop"',
            },
            {
              :type => 'separator',
              :clientType => 'solar',
              :if => 'solarProjectType == "Photovoltaic (PV)"'
            },
            {
              :type => 'heading',
              :text => 'Photovolatic Module Information',
              :clientType => 'solar',
              :if => 'solarProjectType == "Photovoltaic (PV)"'
            },
            {
              :name => 'PV manufacturer',
              :id => 'pvManufacturer',
              :type => 'text',
              :clientType => 'solar',
              :if => 'solarProjectType == "Photovoltaic (PV)"'
            },
            {
              :name => 'PV panels',
              :id => 'pvPanels',
              :type => 'text',
              :clientType => 'solar',
              :placeholder => 'Number of PV panels',
              :if => 'solarProjectType == "Photovoltaic (PV)"'
            },
            {
              :name => 'Nameplate capacity',
              :id => 'pvCapacity',
              :type => 'text',
              :clientType => 'solar',
              :placeholder => 'Generating capacity (kW/MW)',
              :if => 'solarProjectType == "Photovoltaic (PV)"'
            },
            {
              :name => 'Inverter manufacturer',
              :id => 'pvInverterManufacturer',
              :type => 'text',
              :clientType => 'solar',
              :if => 'solarProjectType == "Photovoltaic (PV)"'
            },
            {
              :name => 'Number of inverters',
              :id => 'pvInverterCount',
              :type => 'text',
              :clientType => 'solar',
              :if => 'solarProjectType == "Photovoltaic (PV)"'
            },
            {
              :name => 'Number of transformers',
              :id => 'pvTransformerCount',
              :type => 'text',
              :clientType => 'solar',
              :if => 'solarProjectType == "Photovoltaic (PV)"'
            },
            {
              :name => '',
              :id => 'pvEquipmentUsed',
              :type => 'checkbox',
              :clientType => 'solar',
              :options => {
                'yes' => 'Is any component of the equipment used?'
              },
              :if => 'solarProjectType == "Photovoltaic (PV)"'
            },
            {
              :name => 'Equipment Details',
              :id => 'pvEquipmentDetails',
              :type => 'text',
              :clientType => 'solar',
              :placeholder => 'Provide details including age',
              :if => ['solarProjectType == "Photovoltaic (PV)"', 'pvEquipmentUsed.yes']
            },
            {
              :name => 'Equipment Type',
              :id => 'pvEquipmentType',
              :type => 'dropdown',
              :clientType => 'solar',
              :options => [
                'Self-owned',
                'Leased',
                'Community/Joint ownership',
              ],
              :if => 'solarProjectType == "Photovoltaic (PV)"'
            },
            {
              :name => 'Year Installed',
              :id => 'pvYearInstalled',
              :type => 'text',
              :clientType => 'solar',
              :if => 'solarProjectType == "Photovoltaic (PV)"'
            },
            {
              :name => 'Installer',
              :id => 'pvInstaller',
              :type => 'text',
              :clientType => 'solar',
              :placeholder => 'Who completed the installation?',
              :if => 'solarProjectType == "Photovoltaic (PV)"'
            },
            {
              :name => '',
              :id => 'pvInstallerSIA',
              :type => 'checkbox',
              :clientType => 'solar',
              :options => {
                'yes' => 'Is installer a CanSIA member?'
              },
              :if => 'solarProjectType == "Photovoltaic (PV)"'
            },
            {
              :type => 'separator',
              :clientType => 'solar',
            },
            {
              :name => '',
              :id => 'solarPreventativeMaintenance',
              :type => 'checkbox',
              :clientType => 'solar',
              :options => {
                'yes' => 'Is there a written preventative maintenance program in place?'
              }
            },
            {
              :name => 'Describe',
              :id => 'solarPreventativeMaintenanceDescribe',
              :type => 'text',
              :clientType => 'solar',
              :placeholder => 'If no, what plans exist for maintenance of PV modules and associated equipment?',
              :if => '!solarPreventativeMaintenance.yes'
            },
            {
              :name => 'Spares',
              :id => 'solarSpares',
              :type => 'text',
              :clientType => 'solar',
              :placeholder => 'Details of spares kept off premises',
            },
            {
              :name => '',
              :id => 'solarOwnSubstation',
              :type => 'checkbox',
              :clientType => 'solar',
              :options => {
                'yes' => 'Does applicant own any substation on site?'
              }
            },
            {
              :name => 'Non-owned substation distance',
              :id => 'solarNonOwnedDistance',
              :type => 'text',
              :clientType => 'solar',
              :placeholder => 'Distance of non-owned substation from site location',
            },
            {
              :name => 'Power lines to non-owned substation',
              :id => 'solarNonOwnedDistance',
              :type => 'radio',
              :clientType => 'solar',
              :options => {
                'buried' => 'Buried',
                'onSurface' => 'On surface',
                'overhead' => 'Overhead',
              }
            },
            {
              :name => 'Annual power generation revenue',
              :id => 'solarAnnualRevenue',
              :type => 'text',
              :clientType => 'solar',
              :placeholder => 'Expected annual revenue from power generation',
            },
            {
              :name => '',
              :id => 'solarSystemLog',
              :type => 'checkbox',
              :clientType => 'solar',
              :options => {
                'yes' => 'Do you maintain a log of your system performance?',
              }
            },
            {
              :name => '',
              :id => 'solarSCADA',
              :type => 'checkbox',
              :clientType => 'solar',
              :options => {
                'yes' => 'Is SCADA system provided?'
              }
            },
            {
              :name => 'SCADA signal',
              :id => 'solarSCADASignal',
              :type => 'text',
              :clientType => 'solar',
              :placeholder => 'If yes, where does the SCADA system signal?',
              :if => 'solarSCADA.yes'
            },
            {
              :name => 'Contingency plans',
              :id => 'solarContingencyPlans',
              :type => 'text',
              :clientType => 'solar',
              :placeholder => 'Please describe contingency plans in place for critical equipment failure (i.e. inverters)',
            },
            {
              :name => '',
              :id => 'solarWarranty',
              :type => 'checkbox',
              :clientType => 'solar',
              :options => {
                'yes' => 'Is equipment under manufacturer’s warranty?'
              }
            },
            {
              :name => 'Warranty expiry',
              :id => 'solarWarrantyExpiry',
              :type => 'date',
              :clientType => 'solar',
              :if => 'solarWarranty.yes'
            },
            {
              :type => 'separator',
            },
            {
              :name => 'Risk was inspected',
              :id => 'inspection',
              :type => 'radio',
              :options => {
                'yes' => 'Yes',
                'no' => 'No',
              },
            },
            {
              :name => 'Date Inspected',
              :id => 'inspectionDate',
              :type => 'date',
              :if => 'inspection != "no"',
            },
            {
              :name => 'Inspected by',
              :id => 'inspectedBy',
              :placeholder => 'Person/firm risk was inspected by',
              :type => 'text',
              :if => 'inspection != "no"',
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
              :if => 'inspection != "no"',
            },
            {
              :type => 'separator',
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
          ]
        },
        {
          :name => 'Construction',
          :id => 'construction',
          :type => [
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
                'Steel',
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
              :type => 'heading',
              :text => 'Renovations'
            },
            {
              :name => '',
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
              :type => 'separator',
              :if => 'renovationsElectrical.yes',
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
              :type => 'separator',
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
              :type => 'separator',
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
          ]
        },
        {
          :name => 'Fire Protection',
          :id => 'fireProtection',
          :type => [
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
          ]
        },
        {
          :name => 'Crime Protection',
          :id => 'crimeProtection',
          :type => [
            {
              :name => 'Protection Types',
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
              :type => 'separator',
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
          ]
        },
        {
          :name => 'Occupancy',
          :id => 'occupancy',
          :type => [
            {
              :name => 'Insured',
              :id => 'occupancyInsured',
              :placeholder => 'Description',
              :type => 'textbox',
            },
            {
              :name => 'Others',
              :id => 'occupancyOthers',
              :placeholder => 'Description',
              :type => 'textbox',
            },
          ]
        },
        {
          :name => 'Exposure',
          :id => 'exposure',
          :type => [
            {
              :name => '',
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
              :prefill => {:type => 'sequence'},
              :required => true,
              :primary => true,
            },
            {
              :name => 'Address',
              :id => 'address',
              :type => 'text',
              :placeholder => 'Address (apt., suite, bldg.)',
              :prefill => {
                :type => 'static',
                :text => 'Same as Location',
              },
              :primary => true,
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
                :type => 'static',
                :text => '90%',
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
            { :type => 'separator' },
            {
              :name => 'Coverage Type',
              :id => 'coverageType',
              :type => 'radio',
              :options => {
                'replacementCost' => 'Replacement Cost',
                'actualCashValue' => 'Actual Cash Value',
              }
            },
            {
              :name => 'Amount',
              :id => 'replacementCost',
              :type => 'currency',
              :placeholder => '$ CAN (ex. 111.11)',
              :if => 'coverageType == "replacementCost"',
            },
            {
              :name => 'Amount',
              :id => 'actualCashValue',
              :type => 'currency',
              :placeholder => '$ CAN (ex. 111.11)',
              :if => 'coverageType != "replacementCost"',
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
              :placeholder => '$ CAN (ex. 111.11), calculated from rate and coverage amount',
              :prefill => {
                :type => 'calc',
                :expr => 'buildings.rate.value*(buildings.coverageType.value == "replacementCost" ? buildings.replacementCost.value : buildings.actualCashValue.value)/1000',
              },
            },
          ],
        },
        {
          :name => 'Coverage Sched.',
          :id => 'coverageSchedules',
          :buttonTitle => 'Edit Coverage Scheds.',
          :modalTitle => 'Coverage Schedules',
          :createCallback => 'editCoverageSchedule()',
          :submitCallback => 'saveCoverageSchedules()',
          :editCallback => 'editCoverageSchedule($index)',
          :partial => 'templates/clients/sections/coverage_schedules',
          :type => [
            # Primary field only, for the table. The rest are declared in the partia
            {
              :name => 'Type',
              :id => 'type',
              :required => true,
              :type => 'text',
              :primary => true,
            },
            {
              :id => 'category',
              :required => true,
              :type => 'text',
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
          :coverages => [
            {
              :name => 'Property',
              :id => 'property',
              :type => [
                {
                  :name => 'Building',
                  :id => 'building',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                  :replacementCost => true,
                },
                {
                  :name => 'Equipment',
                  :id => 'equipment',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                  :replacementCost => true,
                },
                {
                  :name => 'Stock',
                  :id => 'stock',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Property of Every Description (POED) ***',
                  :id => 'poed',
                },
                {
                  :name => 'Contents of Every Description (COED) ***',
                  :id => 'coed',
                },
                {
                  :name => 'Office Contents (Broad)',
                  :id => 'officeContents',
                },
                {
                  :name => 'Electronic Data Processing Systems (Broad)',
                  :id => 'electronicDataProcessing',
                },
                {
                  :name => 'Valuable Papers & Records (Broad)',
                  :id => 'valuablePapersRecords',
                },
                {
                  :name => 'Accounts Receivable (Broad)',
                  :id => 'accountsReceivable',
                },
                {
                  :name => 'Residential Condominiums (Broad)',
                  :id => 'residentialCondominiums',
                },
                {
                  :name => 'Commercial Condominiums (Broad)',
                  :id => 'commercialCondominiums',
                },
                {
                  :name => 'Contractor’s Equipment',
                  :id => 'contractorsEquipment',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Tool Floater',
                  :id => 'toolFloater',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Transportation Floater',
                  :id => 'transportationFloater',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Motor Truck Cargo – Owner’s',
                  :id => 'motorTruckCargoOwner',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Motor Truck Cargo – Truckmen’s',
                  :id => 'motorTruckCargoTruckmen',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Trip Transit (Broad)',
                  :id => 'tripTransit',
                },
                {
                  :name => 'Builders Risk',
                  :id => 'buildersRisk',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Installation Floater',
                  :id => 'installationFloater',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Bailees’ Customers',
                  :id => 'baileesCustomers',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Warehouseman’s Legal Liability',
                  :id => 'warehousemansLiability',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Equipment Dealer’s Stock',
                  :id => 'dealersStock',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Equipment Dealer’s Equipment',
                  :id => 'dealersEquipment',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Exhibition Floater',
                  :id => 'exhibitionFloater',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Fine Arts Floater (Broad)',
                  :id => 'fineArtsFloater',
                },
                {
                  :name => 'Signs Floater (Broad)',
                  :id => 'signsFloater',
                },
                {
                  :name => 'Misc. Property Floater',
                  :id => 'miscPropertyFloater',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Furriers Block (Broad)',
                  :id => 'furriersBlock',
                },
                {
                  :name => 'Furriers Customers – Custody Rider (Broad)',
                  :id => 'furriersCustomersCustody',
                },
                {
                  :name => 'Furriers Customers – Legal Liability Rider (Broad)',
                  :id => 'furriersCustomersLiability',
                },
                {
                  :name => 'Jewelers Block (Broad)',
                  :id => 'jewelersBlock',
                },
                {
                  :name => 'Heavy Equipment in Use',
                  :id => 'heavyEquipmentInUse',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Small Equipment in Use',
                  :id => 'smallEquipmentInUse',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Real Property',
                  :id => 'realProperty',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Other Transportation',
                  :id => 'otherTransport',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Other Bailees Floater',
                  :id => 'otherBaileesFloater',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Installment Sales Floater',
                  :id => 'installmentSalesFloater',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Other Sales Operations',
                  :id => 'otherSalesOperations',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Other Construction',
                  :id => 'otherConstruction',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Difference in Conditions',
                  :id => 'differenceInConditions',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Other Misc. Floaters',
                  :id => 'otherMiscFloaters',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Misc. Wording (Broad)',
                  :id => 'miscWordingBroad',
                },
                {
                  :name => 'Misc. Wording (Named)',
                  :id => 'miscWordingNamed',
                },
                {
                  :name => 'Windstorm/Hail',
                  :id => 'miscWordingNamed',
                },
                {
                  :name => 'Flood',
                  :id => 'miscWordingNamed',
                },
                {
                  :name => 'Earthquake',
                  :id => 'miscWordingNamed',
                },
                {
                  :name => 'Lightning',
                  :id => 'miscWordingNamed',
                },
              ],
            },
            {
              :name => 'Business Income',
              :id => 'businessIncome',
              :type => [
                {
                  :name => 'Business Income',
                  :id =>'businessIncome',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Extended Business Income',
                  :id =>'extendedBusinessIncome',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Rental Income',
                  :id =>'rentalIncome',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Extended Rental Income',
                  :id =>'extendedRentalIncome',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Extra Expense',
                  :id =>'extraExpense',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
              ],
            },
            {
              :name => 'Business Interruption',
              :id => 'businessInterruption',
              :type => [
                {
                  :name => 'Profits (Broad/Named)',
                  :id => 'profits',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Gross Earnings–Mercantile or Non-Manufacturing ',
                  :id => 'grossEMOrNM',
                },
                {
                  :name => 'Gross Earnings–Manufacturing',
                  :id => 'grossEarningsManufacturing',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Earnings – No Co-Insurance',
                  :id => 'earningsNoCons',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Rent or Rental Value',
                  :id => 'rentRentalValue',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Gross Rentals',
                  :id => 'grossRentals',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Extra Expense',
                  :id => 'extraExpense',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Other Business Interruption',
                  :id => 'otherBusinessInterruption',
                  :type => {
                    'broad' => 'Broad Form',
                    'named' => 'Named Perils',
                  },
                },
                {
                  :name => 'Misc. Wording (Broad)',
                  :id => 'miscWordingBroad',
                },
                {
                  :name => 'Misc. Wording (Named)',
                  :id => 'miscWordingNamed',
                },
              ],
            },
            {
              :name => 'Crime',
              :id => 'crime',
              :type => [
                {
                  :name => 'Comprehensive 3 D',
                  :id => 'comprehensive3D',
                },
                {
                  :name => 'Employee Dishonesty (Individual)',
                  :id => 'employeeDishonestyIndivid',
                },
                {
                  :name => 'Employee Dishonesty (Scheduled - attach)',
                  :id => 'employeeDishonestySched',
                  :type => {
                    'named' => 'Named Perils',
                    'position' => 'Position',
                  },
                },
                {
                  :name => 'Money & Securities',
                  :id => 'moneySecurities',
                  :type => {
                    'broad' => 'Broad Form',
                    'robbery' => 'Robbery',
                  },
                },
                {
                  :name => 'Money Orders & Counterfeit Paper Currency',
                  :id => 'moneyOrders',
                },
                {
                  :name => 'Depositors Forgery',
                  :id => 'depositorsForgery',
                },
                {
                  :name => 'Damage to Building by Burglary or Robbery',
                  :id => 'damageBuild',
                },
                {
                  :name => 'Stock & Equipment Burglary',
                  :id => 'sAndEBurglary',
                },
                {
                  :name => 'Safe Burglary',
                  :id => 'safeBurglary',
                },
                {
                  :name => 'Safe Deposit Box Burglary & Robbery',
                  :id => 'safeDepositBoxBurglary',
                },
                {
                  :name => 'Safe Deposit Box Securities (Broad)',
                  :id => 'safeDepositBoxSecurities',
                },
                {
                  :name => 'Office Burglary & Robbery',
                  :id => 'officeBurglary',
                  :type => {
                    'fourPoint' => '4 Point',
                    'sevenPoint' => '7 Point',
                  },
                },
                {
                  :name => 'Store Burglary & Robbery (Seven Point)',
                  :id => 'storeBurglary',
                },
                {
                  :name => 'Church Theft',
                  :id => 'churchTheft',
                },
                {
                  :name => 'Misc. Wording',
                  :id => 'miscWording',
                },
              ],
            },
            {
              :name => 'Liability',
              :id => 'liability',
              :type => [
                {
                  :name => 'Commercial General Liability (Occurrence Form)',
                  :id => 'commercialGeneralLiability',
                },
                {
                  :name => 'Comprehensive General Liability',
                  :id => 'comprehensiveGeneralLiability',
                },
                {
                  :name => 'Owners’, Landlords’, and Tenants’ Liability',
                  :id => 'ownersLandlords',
                },
                {
                  :name => 'Tenants’ Legal Liability',
                  :id => 'tenantsLegalLiability',
                  :type => {
                    'broad' => 'Broad Form',
                    'limited' => 'Limited',
                  },
                },
                {
                  :name => 'Non-Owned Automobile Liability (SPF 6)',
                  :id => 'nonOwnedAutoLiability',
                },
                {
                  :name => 'Worldwide Non-owned Automobile Liability',
                  :id => 'wwNonOwnedAuto',
                },
                {
                  :name => 'Voluntary Compensation',
                  :id => 'voluntaryComensation',
                },
                {
                  :name => 'Professional Liability',
                  :id => 'professionalLiability',
                },
                {
                  :name => 'Directors’ & Officers Liability',
                  :id => 'directorsOfficersLiability',
                  :type => {
                    'profit' => 'Profit',
                    'nonProfit' => 'Non profit',
                  },
                },
                {
                  :name => 'Employers’ Bodily Injury Liability',
                  :id => 'employersBodilyInjury',
                },
                {
                  :name => 'Wrap-up Liability',
                  :id => 'wrapUpLiability',
                },
                {
                  :name => 'Pollution Liability',
                  :id => 'pollutionLiability',
                },
                {
                  :name => 'Excess Liability',
                  :id => 'excessLiability',
                },
                {
                  :name => 'Misc. Wording',
                  :id => 'miscWording',
                },
              ],
            },
            {
              :name => 'Umbrella',
              :id => 'umbrella',
              :type => [
                {
                  :name => 'Umbrella Liability',
                  :id => 'umbrellaLiability',
                },
                {
                  :name => 'Misc. Wording',
                  :id => 'miscWording',
                },
              ],
            },
            {
              :name => 'Machinery Breakdown',
              :id => 'machineryBreakdown',
              :type => [
                {
                  :name => 'Machinery Breakdown',
                  :id => 'machineryBreakdown',
                },
                {
                  :name => 'Business Interruption (Actual Loss)',
                  :id => 'businessInterruptionAL',
                },
                {
                  :name => 'Business Interruption (Loss of Profit)',
                  :id => 'businessInterruptionLOP',
                },
                {
                  :name => 'Business Interruption (Gross Earnings)',
                  :id => 'businessInterruptionGE',
                },
                {
                  :name => 'Business Interruption (Rent or Rental Value)',
                  :id => 'businessInterruptionRRV',
                },
                {
                  :name => 'Business Interruption (Extra Expense)',
                  :id => 'businessInterruptionEE',
                },
                {
                  :name => 'Misc. Wording',
                  :id => 'miscWording',
                },
              ],
            },
            {
              :name => 'Other',
              :id => 'other',
              :type => [
                {
                  :name => 'Fees to Substantiate Loss',
                  :id => 'feesToSubstantiateLoss',
                },
                {
                  :name => 'Glass',
                  :id => 'glass',
                },
                {
                  :name => 'Additional Insured',
                  :id => 'additionalInsured',
                },
                {
                  :name => 'Exclusion of Asbestos Related Claims',
                  :id => 'execlusionOfAsbestosRelated',
                },
                {
                  :name => 'Blanket Machinery Breakdown',
                  :id => 'blanketMachinery',
                },
                {
                  :name => 'Misc. Wording',
                  :id => 'miscWording',
                },
              ],
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
              :prefill => {:type => 'sequence'},
              :primary => true,
            },
            {
              :name => 'Unit #',
              :id => 'unitNumber',
              :placeholder => '# ( ex. 1111)',
              :type => 'text',
              :primary => true,
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
              :intelligent => true,
            },
            {
              :name => 'Finance Company',
              :id => 'financeCompany',
              :placeholder => 'Some Truck Co.',
              :intelligent => true,
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
              :intelligent => true,
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
              :intelligent => true,
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
              :prefill => {
                :type => 'watch',
                :watch => 'autoSchedules.dateAdded.value',
                :expr => 'autoSchedules.dateAdded.value + ' + 1.years.to_s,
              },
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
              ],
              :intelligent => true,
              :primary => true,
            },
            {
              :name => 'Item #',
              :id => 'itemNumber',
              :type => 'text',
              :placeholder => '#',
              :prefill => {:type => 'sequence'},
              :required => true,
              :primary => true,
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
              :intelligent => true,
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
              :intelligent => true,
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
              ],
              :intelligent => true,
              :primary => true,
            },
            {
              :name => 'Item #',
              :id => 'itemNumber',
              :type => 'text',
              :placeholder => '#',
              :prefill => {:type => 'sequence'},
              :required => true,
              :primary => true,
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
              :intelligent => true,
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
              :intelligent => true,
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
              :prefill => {:type => 'sequence'},
              :primary => true,
            },
            {
              :name => 'Name',
              :id => 'name',
              :type => 'text',
              :placeholder => 'Firstname Lastname',
              :primary => true,
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
          :name => 'Loss Control Surveys',
          :id => 'lossControlSurveys',
          :buttonTitle => 'Add Survey',
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
              :primary => true,
            },
            {
              :name => 'Person interviewed',
              :id => 'surveyInterviewee',
              :placeholder => 'Name',
              :type => 'text',
            },
            {
              :type => 'heading',
              :text => 'Heating Cooling Systems',
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
              :type => 'heading',
              :text => 'Electrical Systems',
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
              :type => 'heading',
              :text => 'Housekeeping',
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
              :type => 'heading',
              :text => 'Flammable or Combustible Storage',
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
              :type => 'heading',
              :text => 'Fire Protection Equipment',
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
              :type => 'heading',
              :text => 'Physical Protection',
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
              :type => 'heading',
              :text => 'Alarm Protection',
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
              :type => 'heading',
              :text => 'Premises Liability Checklist',
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
              :type => 'heading',
              :text => 'Other',
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
              :primary => true,
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
      :name => 'Blanket Coverages',
      :id => 'blanketCoverages',
      :buttonTitle => 'Edit Coverage Scheds.',
      :modalTitle => 'Blanket Coverage Schedules',
      :createCallback => 'editCoverageSchedule()',
      :submitCallback => 'saveCoverageSchedules()',
      :editCallback => 'editCoverageSchedule($index)',
      :partial => 'templates/clients/sections/coverage_schedules',
      :type => [
        # Primary field only, for the table. The rest are declared in the partia
        {
          :name => 'Type',
          :id => 'type',
          :required => true,
          :type => 'text',
          :primary => true,
        },
        {
          :id => 'category',
          :required => true,
          :type => 'text',
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
          :if => '!newClient.yes',
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
        if !(/^([0-9][-. ]?)?\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})(\s*(ext|x|extension)\.?\s*[0-9]+)?$/i.match(value))
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
    return if field[:id].nil?

    field_name = field[:id].underscore.humanize + (parent ? ' in ' + parent[:id].underscore.humanize.downcase : '')
    val = obj[field[:id]]
    if val.nil?
      if field[:required]
        errors[field_name] << 'is required'
      end
    elsif val['updated_at'].nil?
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
