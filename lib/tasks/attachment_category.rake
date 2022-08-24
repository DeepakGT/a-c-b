namespace :attachment_category do
  desc "Insert the base data of the attachement_category table "
  task fill_category_data: :environment do
    #Attachment Category

    AttachmentCategory.delete_all
    attachment_category_data = [{name: 'VOB'},
                                {name: 'Dx'},
                                {name: 'Dx Video'},
                                {name: 'LMN'},
                                {name: 'Dx Report'},
                                {name: 'Consents'},
                                {name: 'Financial Agreement'},
                                {name: 'Tx Plan'},
                                {name: 'Insurance'},
                                {name: 'Treatment Plan'},
                                {name: 'Referral'},
                                {name: 'Doctor Notes'},
                                {name: 'IEP'},
                                {name: 'Consent Forms'},
                                {name: 'Intake Forms'},
                                {name: 'Parental Questionnaire'},
                                {name: 'ROI'},
                                {name: 'Other'}]

    attachment_category_data.each do |category_data|
      AttachmentCategory.create(category_data)
    end
  end

end
