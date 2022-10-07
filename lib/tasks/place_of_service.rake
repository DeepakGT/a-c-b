namespace :place_of_service do
  desc 'create insert old address_name -> aka'
  task fill: :environment do
    [{tag_num: 3, name: 'School'}, {tag_num: 11, name:'Office'}, {tag_num: 12, name:'Home'},
     {tag_num: 99, name:'Community'}, {tag_num: 10, name:'Telehealth Provided in Patient’s Home'},
     {tag_num: 2, name: 'Telehealth Provided Other than in Patient’s Home'},
     {tag_num: 0, name: 'N/A'}].each { |aka| service_address_type = ServiceAddressType.create(tag_num: aka[:tag_num], name: aka[:name]) }
  end

  task change_service_address: :environment do
    is_home = ['HOME', 'HOME ADDRESS ', 'HOME: 1455 14TH COURT, VERO BEACH, FL 32960', 'HOME: 21366 FALLS RIDGE WAY, BOCA RATON, FL 33428', 'HOME: 18044 JAZZ LANE, BOCA RATON, FL 33496',
               'HOME: 161 WEST ROYAL COVE CIRCLE, DAVIE, FL 33325', "DAD'S HOUSE", "MOM'S HOUSE", 'HOME: 3913 SHELLEY ROAD SOUTH, WEST PALM BEACH, FL 33407', "MOTHER'S HOME ",
               'HOME: 3321 SOUTHWEST PERRINE STREET, PORT ST LUCIE, FL 34953', 'HOME: 1350 NORTHWEST FORK ROAD STUART FL 34994',
               'HOME: 201 SOUTHWEST EYERLY AVENUE', 'HOME: 5225 NORTHWEST REBA CIRCLE, PORT ST LUCIE, FL 34986', 'HOME: 12029 SOUTHWEST 1ST STREET, CORAL SPRINGS, FL 33071', 'DAD HOME',
               "FATHER'S HOME ", ' HOME', 'HOME ADDRESS', 'HOME ']
    is_school = ['SCHOOL', 'CHESTERBROOK ACADEMY:9861 SW VILLAGE PKWY, PORT ST. LUCIE, FL 34987', 'CHESTERBROOK ACADEMY',
                 'BARON ACADEMY: 8555 COMMERCE CENTRE DR, PORT ST. LUCIE, FL 34986', 'BARON ACADEMY: 542 NW UNIVERSITY BLVD STE 101, PORT ST. LUCIE, FL 34986', 'DAYCARE', 'HOMRE']
    is_office = ['CENTER', '34 FFROST DRIVE', 'CLINIC', 'WELLESLEY CLINIC', 'COMMUNITY CENTER', 'NASHUA CLINIC', 'CLINIC: 2400 E COMMERCIAL BLVD SUITE 506, FORT LAUDERDALE, FL 33308',
                 'CRADLES TO CRAYONS: 1285 6TH AVE, VERO BEACH, FL 32960', 'WELLSLEY CENTER ', 'BRAINTREE CENTER', 'BRAINTREE CLINIC', 'OFFICE',
                 'MIDDLETON OFFICE', 'CLINIC: 777 SOUTH FLAGLER DRIVE, SUITE 800 WEST TOWER, WEST PALM BEACH, FL 33401', 'WELLESLEY', 'CLINIC WELLESLEY', 'BILLERICA',
                 'CENTER ', 'CAMP: 9801 DONNA KLEIN BLVD, BOCA RATON, FL', 'CAMP: 7205 ROYAL PALM BLVD, MARGATE, FL 33063', 'CAMP']
    is_community = ['COMMUNITY', 'SOCIAL GROUP', 'COMMUNITY ', 'SOBA', 'ARSI', 'NIMA', "COMMUNITY - GRANDMOTHER'S HOUSE"]
    is_telehealht  = ['TELEHEALTH', 'TELEHEALTH ']                 

 

    cont_limit = Constant.zero
    service_address_types = ServiceAddressType.all.map { |service_address_type| {id: service_address_type.id, name: service_address_type.name, tag_num: service_address_type.tag_num}}
    Address.where(address_type: 'service_address').find_in_batches(batch_size: Constant.limit_service_address_type) do |group|
      group.each do |place_of_service|
        address = Address.find_by id: place_of_service.id
        if is_home.include?(place_of_service.address_name.to_s.upcase)
          service_address = service_address_types.select {|service_address_type| service_address_type[:tag_num].to_i == 12 }
        elsif is_school.include?(place_of_service.address_name.to_s.upcase)
          service_address = service_address_types.select {|service_address_type| service_address_type[:tag_num].to_i == 3 }
        elsif is_office.include?(place_of_service.address_name.to_s.upcase)
          service_address = service_address_types.select {|service_address_type| service_address_type[:tag_num].to_i == 11 }
        elsif is_community.include?(place_of_service.address_name.to_s.upcase)
          service_address = service_address_types.select {|service_address_type| service_address_type[:tag_num].to_i == 99 }
        elsif is_telehealht.include?(place_of_service.address_name.to_s.upcase)
          service_address = service_address_types.select {|service_address_type| service_address_type[:tag_num].to_i == 10 }
        else
          service_address = service_address_types.select {|service_address_type| service_address_type[:tag_num].to_i == 0 }
        end
        puts "service_address #{service_address.inspect}" if service_address.present?
        address.update_attribute :service_address_type_id, service_address[0][:id]
      end
    end
  end
end
