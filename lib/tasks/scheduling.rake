namespace :scheduling do
  # we don't need to run this rake task.
  # It was used when problems in sync were discovered regarding association between soap note and appointment of different client and/or different staff
  desc "Matches and corrects the catalyst data ids in scheduling based on client and staff"
  task correct_catalyst_data_ids: :environment do
    Scheduling.all.each do |schedule|
      if schedule.catalyst_data_ids.present?
        schedule.catalyst_data_ids.each do |catalyst_data_id|
          catalyst_data = CatalystData.find_by(id: catalyst_data_id)
          if catalyst_data.present?
            staff = Staff.where(catalyst_user_id: catalyst_data.catalyst_user_id)
            if staff.count==1
              staff = staff.first
            elsif staff.count>1
              staff = staff.find_by(status: 'active')
            end
            client = Client.where(catalyst_patient_id: catalyst_data.catalyst_patient_id)
            if client.count==1
              client = client.first
            elsif client.count>1
              client = client.find_by(status: 'active')
            end
            if (client.present? && client!=schedule.client_enrollment_service.client_enrollment.client) || (staff.present? && schedule.staff.present? && staff!=schedule.staff)
              schedule.catalyst_data_ids.delete("#{catalyst_data.id}")
              schedule.save(validate: false)
              SoapNote.where(catalyst_data_id: catalyst_data.id)&.update_all(client_id: nil, scheduling_id: nil)
              catalyst_data.system_scheduling_id = nil if catalyst_data.system_scheduling_id==schedule.id
              catalyst_data.multiple_schedulings_ids.delete("#{schedule.id}") if catalyst_data.multiple_schedulings_ids.include?(schedule.id)
              catalyst_data.save(validate: false)
              response_data_hash = CompareCatalystDataWithSystemData::CompareSyncedDataOperation.call(catalyst_data)
            end
          end
        end
      end
    end
  end
end
