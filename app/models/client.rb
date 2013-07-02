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
      :name => 'Company',
      :id => 'company',
      :placeholder => 'Name of Company',
      :type => 'text',
      :required => true,
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
      :name => 'City and Province',
      :id => 'cityAndProvince',
      :placeholder => 'City, Province',
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
      :type => 'text',
    },
    {
      :name => 'Fax',
      :id => 'fax',
      :placeholder => 'Area code - phone #, ext #',
      :type => 'text',
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
          :type => 'text',
          :validatePhone => true,
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
          :placeholder => 'Industry Code (ex. 000000)',
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
          :placeholder => 'dd/mm/yy',
          :type => 'text',
          :required => true,
        },
        {
          :name => 'Type',
          :id => 'type',
          :placeholder => '',
          :type => 'text',
        },
        {
          :name => 'Description',
          :id => 'description',
          :placeholder => '',
          :type => 'textbox',
          :boxRows => 2,
        },
        {
          :name => 'Amount Paid',
          :id => 'amountPaid',
          :placeholder => '',
          :type => 'text',
        },
        {
          :name => 'Reserve',
          :id => 'reserve',
          :placeholder => '',
          :type => 'text',
        },
      ],
    },
    {
      :name => 'Prev. Policy Info',
      :id => 'prevPolicyInfos',
      :type => [
        {
          :name => 'Insurer',
          :id => 'insurer',
          :placeholder => '',
          :type => 'text',
          :required => true,
        },
        {
          :name => 'Broker',
          :id => 'broker',
          :placeholder => '',
          :type => 'text',
        },
        {
          :name => 'Policy #',
          :id => 'policyNumber',
          :placeholder => '',
          :type => 'text',
        },
        {
          :name => 'Premium',
          :id => 'premium',
          :placeholder => '',
          :type => 'text',
        },
        {
          :name => 'Prev. Term',
          :id => 'previousTerm',
          :placeholder => 'Start date - End date',
          :type => 'text',
        },
        {
          :name => 'If renewal was not offered, explain here',
          :id => 'renewalExplanation',
          :placeholder => '',
          :type => 'textbox',
          :boxRows => 6,
        },
      ],
    },
    {
      :name => 'Liability Info',
      :id => 'liabilityInfos',
      :type => [
        {
          :name => 'Stub',
          :id => 'stub',
          :type => 'text'
        }
      ],
    },
    {
      :name => 'Policy Info',
      :id => 'policyInfos',
      :type => [
        {
          :name => 'Stub',
          :id => 'stub',
          :type => 'text'
        }
      ],
    },
    {
      :name => 'Payment Info',
      :id => 'paymentInfos',
      :type => [
        {
          :name => 'Stub',
          :id => 'stub',
          :type => 'text'
        }
      ],
    },
    {
      :name => 'Location Info',
      :id => 'locationInfos',
      :type => [
        {
          :name => 'Location Number',
          :id => 'locationNumber',
          :placeholder => '#',
          :type => 'text',
        },
        {
          :name => 'This location Is',
          :id => 'lofationType',
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
          :type => 'text',
        },
        {
          :name => 'City',
          :id => 'locationCity',
          :type => 'text',
        },
        {
          :name => 'Country',
          :id => 'locationCountry',
          :type => 'text',
        },
        {
          :name => 'Province/State',
          :id => 'locationProvinceState',
          :type => 'text',
        },
        {
          :name => 'Postal Code',
          :id => 'locationPostalCode',
          :type => 'text',
        },
        {
          :name => 'Date',
          :id => 'inspectionDate',
          :placeholder => 'Date risk was inspected',
          :type => 'text',
        },
        {
          :name => 'Inspection',
          :id => 'inspection',
          :type => 'radio',
          :options => {
            'notInspected' => 'This risk was not inspected',
          },
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
        },
        {
          :name => 'Municipal fire zone',
          :id => 'fireZone',
          :placeholder => 'Municipal fire protection zone',
          :type => 'text',
        },
        {
          :name =>'Fire Protection Grade',
          :id => 'fireGrade',
          :placeholder => 'Fire Protection Grade',
          :type => 'text',
        },
      ],
    },
    {
      :name => 'Risk Info',
      :id => 'riskInfos',
      :type => [
        {
          :name => 'Type',
          :id => 'type',
          :type => 'dropdown',
          :placeholder => '',
          :options => [
            'Commercial Building',
            'Commercial Equipment',
            'Commercial Stock',
            'Other Commercial Risk',
          ],
        },
        {
          :name => 'Notes',
          :id => 'riskInfosNotes',
          :type => 'textbox',
        },
        {
          :name => 'Limit',
          :id => 'riskInfosLimit',
          :type => 'text',
        },
        {
          :name => 'Stories',
          :id => 'constructionStories',
          :type => 'text',
        },
        {
          :name => 'Walls',
          :id => 'constructionWalls',
          :type => 'checkbox',
          :options => {
            'fireResistive' => 'Fire Resistive',
            'nonCombustableMasonryWalls' => 'Non-Combustable Masonry Walls',
            'nonCombustableNonMasonryWalls' => 'Non-Combustable Non-masonry Walls',
            'masonry' => 'Masonry',
            'masonryVeneer' => 'Masonry Veneer',
            'frameAndAllOthers' => 'Frame & All Others',
          },
        },
        {
          :name => 'Roof',
          :id => 'constructionRoof',
          :type => 'checkbox',
          :options => {
            'steelDeck' => 'Steel Deck',
            'tarPaper' => 'Tar Paper',
            'TandG' => 'T & G',
            'metal' => 'Metal',
            'slate' => 'Slate',
            'tile' => 'Tile',
            'asphaltShingles' => 'Ashphalt Shingles',
            'woodShingles' => 'Wood Shingles',
            'woodShakes' => 'Wood Shakes',
            'rubber' => 'Rubber',
            'plastic' => 'Plastic',
            'other' => 'Other (describe)',
          },
        },
        {
          :name => 'Describe',
          :id => 'constructionRoofDescribe',
          :placeholder => 'If Other, Please Describe',
          :type => 'text',
        },
        {
          :name => 'Floors',
          :id => 'constructionFloors',
          :type => 'checkbox',
          :options => {
            'fireResistive' => 'Fire Resistive',
            'nonCombustableMasonryWalls' => 'Non-Combustable Masonry Walls',
            'nonCombustableNonMasonryWalls' => 'Non-Combustable Non-masonry Walls',
            'masonry' => 'Masonry',
            'masonryVeneer' => 'Masonry Veneer',
            'frameAndAllOthers' => 'Frame & All Others',
          },
        },
        {
          :name => 'Area',
          :id => 'constructionArea',
          :placeholder => 'Number Only',
          :type => 'text',
        },
        {
          :name => 'Area Units',
          :id => 'constructionAreaUnit',
          :type => 'dropdown',
          :options => [
            'Ft&sup2;',
            'm&sup2;',
          ],
        },
        {
          :name => 'Year Built',
          :id => 'yearBuilt',
          :placeholder => '#',
          :type => 'text',
        },
        {
          :name => 'Basement',
          :id => 'constructionBasement',
          :type => 'checkbox',
          :options => {
            'fireResistive' => 'Fire Resistive',
            'nonCombustableMasonryWalls' => 'Non-Combustable Masonry Walls',
            'nonCombustableNonMasonryWalls' => 'Non-Combustable Non-masonry Walls',
            'masonry' => 'Masonry',
            'masonryVeneer' => 'Masonry Veneer',
            'frameAndAllOthers' => 'Frame & All Others',
            'notApplicable' => 'Not Applicable',
          },
        },
        {
          :name => 'Electrical',
          :id => 'constructionElectrical',
          :type => 'checkbox',
          :options => {
            'breakers' => 'Breakers',
            'fuses' => 'Fuses',
            'breakersAndFuses' => 'Breakers & Fuses',
          },
        },
        {
          :name => 'Plumbing',
          :id => 'constructionPlumbing',
          :type => 'checkbox',
          :options => {
            'copper' => 'Copper',
            'lead' => 'Lead',
            'plastic' => 'Plastic (PVC or CVS)',
            'galvanized' => 'Galvanized',
            'stainlessSteel' => 'Stainless Steel',
            'steel' => 'Steel',
          },
        },
        {
          :name => 'Heating',
          :id => 'constructionHeating',
          :type => 'checkbox',
          :options => {
            'none' => 'None',
            'ductFurnace' => 'Duct Furnace',
            'boiler' => 'Boiler',
            'radiant' => 'Radient',
            'electric' => 'Electric',
            'furnaceCentral' => 'Furnace (Central)',
            'floorFurnace' => 'Floor Furnace',
            'spaceHeater' => 'Space Heater',
            'other' => 'Other (describe)'
          },
        },
        {
          :name => 'Describe',
          :id => 'constructionHeatingDescribe',
          :placeholder => 'If Other, Please Describe',
          :type => 'text',
        },
        {
          :name => 'Fuel',
          :id => 'constructionFuel',
          :type => 'checkbox',
          :options => {
            'oil' => 'Oil',
            'naturalGas' => 'Natural Gas',
            'propane' => 'Propane',
            'steam' => 'Steam',
            'wood' => 'Wood',
            'electric' => 'Electric',
            'other' => 'Other (describe)',
          },
        },
        {
          :name => 'Describe',
          :id => 'constructionFuelDescribe',
          :placeholder => 'If Other, Please Describe',
          :type => 'text',
        },
        {
          :name => 'Renovations',
          :id => 'renovationsType',
          :type => 'checkbox',
          :options => {
            'noneKnown' => 'None Known',
          },
        },
        {
          :name => '',
          :id => 'renovationsElectrical',
          :type => 'checkbox',
          :options => {
            'electricalRenovation' => 'Electrical',
          },
        },
        {
          :name => 'Year of Renovation',
          :id => 'renovationsElectricalYear',
          :type => 'text',
          :placeholder => '#',
        },
        {
          :name => 'Complete/Partial',
          :id => 'renovationsElectricalCompletePartial',
          :type => 'text',
          :placeholder => 'Complete/Partial',
        },
        {
          :name => '',
          :id => 'renovationsPlumbing',
          :type => 'checkbox',
          :options => {
            'plumbingRenovation' => 'Plumbing',
          },
        },
        {
          :name => 'Year of Renovation',
          :id => 'renovationsPlumbingYear',
          :type => 'text',
          :placeholder => '#',
        },
        {
          :name => 'Complete/Partial',
          :id => 'renovationsPlumbingCompletePartial',
          :type => 'text',
          :placeholder => 'Complete/Partial',
        },
        {
          :name => '',
          :id => 'renovationsHeating',
          :type => 'checkbox',
          :options => {
            'heatingRenovation' => 'Heating',
          },
        },
        {
          :name => 'Year of Renovation',
          :id => 'renovationsHeatingYear',
          :type => 'text',
          :placeholder => '#',
        },
        {
          :name => 'Complete/Partial',
          :id => 'renovationsHeatingCompletePartial',
          :type => 'text',
          :placeholder => 'Complete/Partial',
        },
        {
          :name => '',
          :id => 'renovationsRoof',
          :type => 'checkbox',
          :options => {
            'roofRenovation' => 'Roof',
          },
        },
        {
          :name => 'Year of Renovation',
          :id => 'renovationsRoofYear',
          :type => 'text',
          :placeholder => '#',
        },
        {
          :name => 'Complete/Partial',
          :id => 'renovationsRoofCompletePartial',
          :type => 'text',
          :placeholder => 'Complete/Partial',
        },
        {
          :name => 'Fire Hydrants',
          :id => 'fireHydrants',
          :type => 'dropdown',
          :placeholder => '',
          :options => [
            'Unprotected',
            'Within 150m',
            'Within 300m',
            'Over 300m',
          ],
        },
        {
          :name => 'Fire Department',
          :id => 'fireDepartment',
          :type => 'dropdown',
          :placeholder => '',
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
          :type => 'checkbox',
          :options => {
            'portableExtinguisher' => 'Portable Extinguishing(s)',
            'sprinkler' => 'Sprinkler',
            'none' => 'None',
            'other' => 'Other (describe)',
          },
        },
        {
          :name => 'Describe',
          :id => 'extinguishingSystemDescribe',
          :placeholder => 'If Other, Please Describe',
          :type => 'text',
        },
        {
          :name => 'Extinguishing Agent',
          :id => 'extinguishingAgent',
          :type => 'checkbox',
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
          :type => 'checkbox',
          :options => {
            'none' => 'None',
            'complete' => 'Complete',
            'centralStation' => 'Central Station',
            'monitoringstationFull' => 'Monitoring Station (Full)',
            'monitoringstationShared' => 'Monitoring Station (Shared)',
            'localAlarm' => 'Local Alarm',
            'other' => 'Other (describe)',
          },
        },
        {
          :name => 'Describe',
          :id => 'fireAlarmDescribe',
          :placeholder => 'If Other, Please Describe',
          :type => 'text',
        },
        {
          :name => 'Coverage %',
          :id => 'coveragePercent',
          :placeholder => '#',
          :type => 'text',
        },
        {
          :id => 'standpipe',
          :type => 'checkbox',
          :options => {
            'standpipeAndHose' => 'Standpipe & Hose',
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
            'deadbolt' => 'Doors -Deadbolt',
            'breakResistantGlass' => 'Break Reisitant Glass',
            'WindowsBarred' => 'Windows -barred',
            'WindowsWireMesh' => 'Windows -Wire Mesh',
            'SteelBars' => 'Steel Bars on Openings',
            'cameras' => 'Surveillance Cameras',
            'watchmen' => 'watchmen/Security Guards',
            'fence' => 'Fence',
            'GuardDog' => 'Guard Dog',
            'WindowsULC' => 'Windows -ULC Security Film',
            'aditionalComboLock' => 'Aditional Combo Lock',
            'aditionalKey' => 'Aditional Key',
            'fineWireprotection' => 'Alarm \'fine wire\' protecting openings',
            'commonWallsReinforced' => 'Common Tennant Walls Reinforced with Steel Mesh',
            'exteriorLighting' => 'Exterior Lighting',
            'electronicLock' => 'Electronic Lock',
            'enterancevisable' => 'Enterance Visable From Street',
            'ExteriorDoorsSturdy' => 'Exterior Doors Of Sturdy Construction, Hinges Inside',
            'holdUpButtons' => 'Hold-Up Buttons',
            'metalLoadingDoors' => 'Metal Loading Doors, Secured Internal',
            'motionsensitivelighting' => 'Motion Sensitive Lighting',
            'multipleLockStyles' => 'Multiple Lock Styles',
            'permiterFenceLockable' => 'Perimitor FEince and Gate Lockable',
            'lotIluminatedNight' => 'Property/Lot Iluminated at Night',
            'SkyOpenigsBlocked' => 'Skylignt/Roof AC Openings Blocked Off',
            'steelPostPreventEntery' => 'Steel Post (frint & back) to Prevent veichale entery',
            'stockSecured' => 'Stock Secured -Seperate Enclosure',
            'stockroomCeilingMotionSensor' => 'Stockroom Ceiling Entirely Covered By Motion Sensor',
            'warehouseAlarmedSeperately' => 'Warehouse Alarmed Seperately from Office',
            'warningSighs' => 'Warning Signs',
            'WindowsBreakageDetectors' => 'Windows -Glass Breakage Detectors',
          },
        },
        {
          :name => 'Burglar Alarm',
          :id => 'burglarAlarm',
          :type => 'checkbox',
          :options => {
            'none' => 'None',
            'complete' => 'Complete',
            'partial' => 'Partial',
            'centralStation' => 'Central Station',
            'monitoringstationFull' => 'Monitoring Station (Full)',
            'monitoringstationPartial' => 'Monitoring Station (Partial)',
            'local' => 'Local',
            'other' => 'Other (describe)',
          },
        },
        {
          :name => 'Describe',
          :id => 'burglarAlarmDescribe',
          :placeholder => 'If Other, Please Describe',
          :type => 'text',
        },
      ],
    },
    {
      :name => 'Misc. Notes',
      :id => 'miscNotes',
      :type => [
        {
          :name => 'Stub',
          :id => 'stub',
          :type => 'text'
        }
      ],
    },
    {
      :name => 'Coverage',
      :id => 'coverages',
      :type => [
        {
          :name => 'Stub',
          :id => 'stub',
          :type => 'text'
        }
      ],
    },
    {
      :name => 'Properties',
      :id => 'properties',
      :type => [
        {
          :name => 'Stub',
          :id => 'stub',
          :type => 'text'
        }
      ],
    },
    {
      :name => 'Umbrella/Machinery',
      :id => 'umbrellaMachinerys',
      :type => [
        {
          :name => 'Stub',
          :id => 'stub',
          :type => 'text'
        }
      ],
    },
    {
      :name => 'Photos',
      :id => 'photos',
      :type => [
        {
          :name => 'Stub',
          :id => 'stub',
          :type => 'text'
        }
      ],
    },
  ]

  def validate_scalar(field_name, field_desc, value)
    if value.nil?
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
      end
    end

    return value
  end

  def valid?(context = nil)
    errors.clear
    # Custom validation.
    FIELDS.each do |field|
      val = self[field[:id]]

      if val.nil?
        if field[:required]
          errors[field[:id]] << 'is required'
        end
      elsif val['updated_at'].nil?
        errors[field[:id]] << 'must contain "updated_at"'
      elsif val['value'].nil?
        if field[:type].is_a?(Array)
          # Rails parses empty arrays as nil. Assume that's what happened
          val['value'] = []
        else
          errors[field[:id]] << 'must contain "value"'
        end
      elsif field[:type].is_a?(Array)
        if !val['value'].is_a?(Array)
          errors[field[:id]] << 'must be an array'
        else
          val['value'].each_with_index do |subval, i|
            field[:type].each do |subfield|
              subval[subfield[:id]] = validate_scalar(subfield[:id], subfield, subval[subfield[:id]])
            end
          end
        end
      else
        val['value'] = validate_scalar(field[:id], field, val['value'])
      end
    end

    errors.empty? && super(context)
  end
end
