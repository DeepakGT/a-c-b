json.status @office_address.errors.present? ? 'failure' : 'success'
json.data json.partial! 'service_address_detail', service_address: @office_address unless @office_address.errors.present?
json.errors @office_address.errors.map{|error| error} if @office_address.errors.present?
