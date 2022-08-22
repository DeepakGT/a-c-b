FactoryBot.define do
  factory :scheduling_change_request do
    scheduling_id {create(:scheduling).id}
    date { '2876-07-15' }
    start_time { (DateTime.current+0.1).strftime('%H:%M') }
    end_time { (DateTime.current+0.3).strftime('%H:%M') }
    status {'Client_Cancel_Greater_Than_24_h'}
  end
end
