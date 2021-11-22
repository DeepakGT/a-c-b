class AddressSerializer < ApplicationSerializer
  attributes :id, :line1, :line2, :line3, :zipcode, :city, :state, :country
end
