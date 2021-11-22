class ServiceSerializer < ApplicationSerializer
  attributes :id, :name, :status, :default_pay_code, :category,
             :display_pay_code, :tracking_id
end
