namespace :client do
  desc "Update office address of client when location address are added"
  task update_office_address: :environment do
    service_addresses = Address.where(addressable_type: 'Client', address_name: 'Office', address_type: 'service_address')
    service_addresses.each do |service_address|
      client = Client.find_by(id: service_address.addressable_id)
      if client.clinic.address.present?
        address = client.clinic.address
        service_address.update(line1: address.line1, city: address.city, state: address.state, country: address.country, zipcode: address.zipcode)
      end
    end
  end
end
