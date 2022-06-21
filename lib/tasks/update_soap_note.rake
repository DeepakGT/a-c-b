namespace :update_soap_note do
  desc "Update client_id in soap_notes"
  task update_client_id: :environment do
    SoapNote.all.each do |soap_note|
      if soap_note.scheduling_id.present?
        soap_note.client_id = soap_note.scheduling.client_enrollment_service.client_enrollment.client.id
        soap_note.save(validate: false)
      elsif soap_note.catalyst_data_id.present?
        catalyst_patient_id = CatalystData.find(soap_note.catalyst_data_id).catalyst_patient_id
        client = Client.where(catalyst_patient_id: catalyst_patient_id)
        if client.count==1
          client = client.first
        elsif client.count>1
          client = client.find_by(status: 'active')
        end
        if client.present?
          soap_note.client_id = client.id
          soap_note.save(validate: false)
        end
      end
    end
  end
end
