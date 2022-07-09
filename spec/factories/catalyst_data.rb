FactoryBot.define do
  factory :catalyst_data do
    date { (Time.current-5.days).strftime('%Y-%m-%d') }
    start_time { '13:30' }
    end_time { '14:30' }
    note { 'test-note' }
    units { 4 }
    minutes { 60 }
    bcba_signature {'present'}
    clinical_director_signature {'present'}
    caregiver_signature {'present'}
    provider_signature {'present'}
  end
end
