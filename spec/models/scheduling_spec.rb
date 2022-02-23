require 'rails_helper'

RSpec.describe Scheduling, type: :model do
  it { should belong_to(:staff) }
  it { should belong_to(:client_enrollment_service) }
  
  it do
    should define_enum_for(:status).
      with_values(
        scheduled: 'scheduled',
        client_cancel_greater_than_24_h: 'Client Cancel Greater than 24 h',
        client_cancel_less_than_24_h: 'Client Cancel Less than 24 h',
        client_no_show: 'Client No Show',
        non_billable: 'Non-Billable',
        staff_cancellation: 'Staff Cancellation',
        unavailable: 'unavailable'
      ).
      backed_by_column_of_type(:string)
  end
end
