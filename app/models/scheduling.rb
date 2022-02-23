class Scheduling < ApplicationRecord
  belongs_to :staff
  belongs_to :client
  belongs_to :service

  enum status: { scheduled: 'scheduled',
                 client_cancel_greater_than_24_h: 'Client Cancel Greater than 24 h',
                 client_cancel_less_than_24_h: 'Client Cancel Less than 24 h',
                 client_no_show: 'Client No Show',
                 non_billable: 'Non-Billable',
                 staff_cancellation: 'Staff Cancellation',
                 unavailable: 'unavailable'
               }
end
