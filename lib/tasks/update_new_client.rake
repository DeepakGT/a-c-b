namespace :update_new_client do
  desc "Copy client data to new_client"
  task copy_client_data: :environment do
    Client.all.each do |client|
      new_client = NewClient.create(id: client.id, first_name: client.first_name, last_name: client.last_name, email: client.email, gender: client.gender, 
                                    disqualified: client.disqualified, dq_reason: client.dq_reason, preferred_language: client.preferred_language, 
                                    dob: client.dob, status: client.status, payor_status: client.payor_status, clinic_id: client.clinic_id, 
                                    bcba_id: client.bcba_id)
      Address.where(addressable_type: 'User', addressable_id: client.id)&.update_all(addressable_type: 'NewClient', addressable_id: new_client.id)
      PhoneNumber.where(phoneable_type: 'User', phoneable_id: client.id)&.update_all(phoneable_type: 'NewClient', phoneable_id: new_client.id)
      Attachment.where(attachable_type: 'User', attachable_id: client.id)&.update_all(attachable_type: 'NewClient', attachable_id: new_client.id)
    end
  end

  desc "Copy client_id in contacts, client_enrollments and client_notes"
  task update_new_client_ids: :environment do
    Contact.all.each do |contact|
      contact.new_client_id = contact.client_id
      contact.save(validate: false)
    end

    ClientEnrollment.all.each do |client_enrollment|
      client_enrollment.new_client_id = client_enrollment.client_id
      client_enrollment.save(validate: false)
    end

    ClientNote.all.each do |client_note|
      client_note.new_client_id = client_note.client_id
      client_note.save(validate: false)
    end
  end

  desc "Copy old_client_id in contacts, client_enrollments and client_notes"
  task update_client_ids: :environment do
    Contact.all.each do |contact|
      contact.client_id = contact.new_client_id
      contact.save(validate: false)
    end

    ClientEnrollment.all.each do |client_enrollment|
      client_enrollment.client_id = client_enrollment.new_client_id
      client_enrollment.save(validate: false)
    end

    ClientNote.all.each do |client_note|
      client_note.client_id = client_note.new_client_id
      client_note.save(validate: false)
    end
  end

  desc "Rename new client to client in polymorphic associations"
  task rename_new_client: :environment do
    Address.where(addressable_type: 'NewClient')&.update_all(addressable_type: 'Client')
    PhoneNumber.where(phoneable_type: 'NewClient')&.update_all(phoneable_type: 'Client')
    Attachment.where(attachable_type: 'NewClient')&.update_all(attachable_type: 'Client')
  end
end
