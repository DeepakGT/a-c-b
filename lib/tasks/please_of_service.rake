namespace :please_of_service do
  desc 'create insert old address_name -> aka'
  task fill: :environment do
    [{tag_num: 3, name: "School"}, {tag_num: 11, name:"Office"}, {tag_num: 12, name:"Home"}, {tag_num: 99, name:"Community"}, {tag_num: 10, name:"Telehealth"}].each { |aka| service_address_type = ServiceAddressType.create(tag_num: aka[:tag_num], name: aka[:name]) }
  end

  task change_service_address: :environment do
    cont_limit = Constant.zero
    service_address_types = ServiceAddressType.all.map { |service_address_type| {id: service_address_type.id, name: service_address_type.name}}
    Address.where(address_type: "service_address").each do |please_of_service|
      address = Address.find_by(id: please_of_service.id)
      service_address = service_address_types.select {|service_address_type| service_address_type[:name] == please_of_service.address_name.upcase_first}
      address.update_attribute :service_address_type_id, service_address[0][:id]
      sleep(0.5) if cont_limit >= Constant.limit_service_address_type
      cont_limit = Constant.zero if cont_limit == Constant.limit_service_address_type
      cont_limit += Constant.one
    end
  end
end
