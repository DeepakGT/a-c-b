namespace :db do
  desc "Seed production data"
  task seed_production: :environment do
    puts "Production data seed is in progress..."
    ActiveRecord::Base.transaction do
      # Role
      UserRole.destroy_all
      Role.delete_all
      Role.find_or_create_by!(name: 'super_admin')
      Role.find_or_create_by!(name: 'executive_director')
      Role.find_or_create_by!(name: 'administrator')
      Role.find_or_create_by!(name: 'bcba')
      Role.find_or_create_by!(name: 'rbt')
      Role.find_or_create_by!(name: 'billing')
    
      # create a user with role super_admin
      User.delete_all
      User.where(email: "super_admin_user@yopmail.com").first_or_create! do |u|
        # This block will run only on create new records
        # i.e. if record found, this block would be skip
        u.first_name, u.last_name = Faker::Name.unique.name.split(' ')
        u.password = Rails.application.credentials.dig(:default_super_admin_password)
        u.role = Role.find_by(name: 'super_admin')
      end

      # create an executive director user
      User.where(email: "executive_director_user@yopmail.com").first_or_create! do |u|
        # This block will run only on create new records
        # i.e. if record found, this block would be skip
        u.first_name, u.last_name = Faker::Name.unique.name.split(' ')
        u.password = Rails.application.credentials.dig(:default_super_admin_password)
        u.role = Role.find_by(name: 'executive_director')
      end
    
      # Country List
      Country.delete_all
      ISO3166::Country.all.each do |country|
        Country.create(name: country.name, code: country.alpha3)
      end
    end
    puts "Production data seed completed. Thank You!"
  end

  desc "Seed production data from staging"
  task seed_data_from_staging: :environment do
    puts "Production data seed from staging data is in progress..."
    ActiveRecord::Base.transaction do
      #organizations
      Organization.delete_all
      organizations = [{"id"=>1, "name"=>"ABA Centers of America", "aka"=>"abaca", "web"=>"www.abacenters.com", "email"=>"aba@abacenter.socm", "status"=>"active"}]
      organizations.each do |organization|
        Organization.where(id: organization['id'], name: organization['name'], aka: organization['aka'], web: organization['web'], email: organization['email'], status: organization['status']).first_or_create! do |org|
          org.admin_id = User.find_by(email: 'executive_director_user@yopmail.com').id
        end
      end

      #clinics
      Clinic.delete_all
      clinics = [{"id"=>4, "name"=>"test location1", "aka"=>"2342", "web"=>nil, "email"=>"test@gmail.com", "status"=>"active", "organization_id"=>1, "catalyst_clinic_id"=> nil},
                {"id"=>1, "name"=>"Bedford, NH", "aka"=>"bedford", "web"=>nil, "email"=>"bedford@abacenters.com", "status"=>"active", "organization_id"=>1, "catalyst_clinic_id"=> nil},
                {"id"=>8, "name"=>"Peabody, MA", "aka"=>"pebody", "web"=>nil, "email"=>"peabody@abacenters.com", "status"=>"active", "organization_id"=>1, "catalyst_clinic_id"=> nil},
                {"id"=>9, "name"=>"Porthsmouth, NH", "aka"=>"portsmouth", "web"=>nil, "email"=>"ports@abacenters.com", "status"=>"active", "organization_id"=>1, "catalyst_clinic_id"=> nil},
                {"id"=>10, "name"=>"South East, FL", "aka"=>"southeast", "web"=>nil, "email"=>"sourthfl@abacenters.com", "status"=>"active", "organization_id"=>1, "catalyst_clinic_id"=> nil},
                {"id"=>11, "name"=>"Wellesley, MA", "aka"=>"wellesley", "web"=>nil, "email"=>"welles@abacetners.com", "status"=>"active", "organization_id"=>1, "catalyst_clinic_id"=> nil},
                {"id"=>13, "name"=>"Corporate, FL", "aka"=>"corporate", "web"=>nil, "email"=>"corproate@abacenters.com", "status"=>"active", "organization_id"=>1, "catalyst_clinic_id"=> nil},
                {"id"=>2, "name"=>"Nashua, NH", "aka"=>"nashua", "web"=>nil, "email"=>"nashua@abacenters.com", "status"=>"active", "organization_id"=>1, "catalyst_clinic_id"=> nil},
                {"id"=>7, "name"=>"Salem, NH", "aka"=>"nashuasouth", "web"=>nil, "email"=>"sdfd@abacenters.com", "status"=>"active", "organization_id"=>1, "catalyst_clinic_id"=> nil},
                {"id"=>6, "name"=>"Braintree, MA", "aka"=>"braintree", "web"=>nil, "email"=>"brain@abacenters.com", "status"=>"active", "organization_id"=>1, "catalyst_clinic_id"=>"7ba6dec9-18e2-4f39-8661-1fd2b33952cd"},
                {"id"=>14, "name"=>"testloc", "aka"=>"tl", "web"=>nil, "email"=>"asdasd@sew.cft", "status"=>"active", "organization_id"=>1, "catalyst_clinic_id"=> nil},
                {"id"=>12, "name"=>"Worcester, MA", "aka"=>"worcester", "web"=>nil, "email"=>"well@abacetners.com", "status"=>"active", "organization_id"=>1, "catalyst_clinic_id"=>"f9d4458b-9b5c-4a26-9678-0469afb207a8"}]

      clinics.each do |clinic|
        Clinic.where(id: clinic['id'], name: clinic['name'], aka: clinic['aka'], web: clinic['web'], email: clinic['email'], status: clinic['status'], catalyst_clinic_id: clinic['catalyst_clinic_id']).first_or_create! do |loc|
          loc.organization_id = clinic['organization_id']
        end
      end

      # services
      Service.delete_all
      services = [{"id"=>9, "name"=>"Direct Service", "status"=>"active", "display_code"=>"97153", "is_service_provider_required"=>false},
                 {"id"=>15, "name"=>"Developmental test administration by physician or", "status"=>"active", "display_code"=>"96112", "is_service_provider_required"=>nil},
                 {"id"=>16, "name"=>"Additional 30 minutes spent performing activities", "status"=>"active", "display_code"=>"96113", "is_service_provider_required"=>nil},
                 {"id"=>10, "name"=>"Initial Assessment", "status"=>"active", "display_code"=>"97151", "is_service_provider_required"=>true},
                 {"id"=>2, "name"=>"Re-Assessment", "status"=>"active", "display_code"=>"97151", "is_service_provider_required"=>true},
                 {"id"=>3, "name"=>"Caregiver Training", "status"=>"active", "display_code"=>"97156", "is_service_provider_required"=>false},
                 {"id"=>18, "name"=>"Early Assessment", "status"=>"active", "display_code"=>"98888", "is_service_provider_required"=>nil},
                 {"id"=>20, "name"=>"Early Caregiver Training", "status"=>"active", "display_code"=>"99998", "is_service_provider_required"=>nil},
                 {"id"=>21, "name"=>"Early Direct Service", "status"=>"active", "display_code"=>"99999", "is_service_provider_required"=>nil},
                 {"id"=>22, "name"=>"Case Management/Treatment Plan Review", "status"=>"active", "display_code"=>"H0032", "is_service_provider_required"=>nil},
                 {"id"=>17, "name"=>"Supervision", "status"=>"active", "display_code"=>"97155", "is_service_provider_required"=>true},
                 {"id"=>19, "name"=>"Early Supervision", "status"=>"active", "display_code"=>"99997", "is_service_provider_required"=>true}]

      services.each do |service|
        Service.where(id: service['id'], name: service['name'], status: service['status'], display_code: service['display_code'], is_service_provider_required: service['is_service_provider_required']).first_or_create!
      end

      # funding sources
      FundingSource.delete_all
      funding_sources = [{"id"=>13, "name"=>"Sushma", "plan_name"=>"PlanA", "payor_type"=>"commercial", "email"=>"asds@gmail.com", "notes"=>"eetetq", "clinic_id"=>1, "network_status"=>"in_network", "status"=>"inactive"},
                        {"id"=>12, "name"=>"sushma", "plan_name"=>"funds", "payor_type"=>"commercial", "email"=>"sushma.n+fundingsource1@sigmainfo.net", "notes"=>"test1", "clinic_id"=>1, "network_status"=>"out_of_network", "status"=>"inactive"},
                        {"id"=>15, "name"=>"ABA Centers of America", "plan_name"=>"", "payor_type"=>"commercial", "email"=>"", "notes"=>"", "clinic_id"=>1, "network_status"=>"in_network", "status"=>"active"},
                        {"id"=>1, "name"=>"Aetna", "plan_name"=>"", "payor_type"=>"commercial", "email"=>"", "notes"=>"", "clinic_id"=>1, "network_status"=>"out_of_network", "status"=>"active"},
                        {"id"=>2, "name"=>"Ambetter nnhf", "plan_name"=>"", "payor_type"=>"medicaid", "email"=>"", "notes"=>"", "clinic_id"=>1, "network_status"=>"out_of_network", "status"=>"active"},
                        {"id"=>3, "name"=>"Amerihealth caritas nh", "plan_name"=>"", "payor_type"=>"medicaid", "email"=>"", "notes"=>"", "clinic_id"=>1, "network_status"=>"out_of_network", "status"=>"active"},
                        {"id"=>16, "name"=>"Beacon Health Options", "plan_name"=>"", "payor_type"=>"commercial", "email"=>"", "notes"=>"", "clinic_id"=>1, "network_status"=>"out_of_network", "status"=>"active"},
                        {"id"=>4, "name"=>"Beacon health strategies", "plan_name"=>"", "payor_type"=>"commercial", "email"=>"", "notes"=>"", "clinic_id"=>1, "network_status"=>"out_of_network", "status"=>"active"},
                        {"id"=>5, "name"=>"Cigna", "plan_name"=>"", "payor_type"=>"commercial", "email"=>"", "notes"=>"", "clinic_id"=>1, "network_status"=>"out_of_network", "status"=>"active"},
                        {"id"=>6, "name"=>"Harvard pilgrim", "plan_name"=>"", "payor_type"=>"commercial", "email"=>"", "notes"=>"", "clinic_id"=>1, "network_status"=>"out_of_network", "status"=>"active"},
                        {"id"=>17, "name"=>"MA Behavoiral HP (MBHP)", "plan_name"=>"", "payor_type"=>"commercial", "email"=>"", "notes"=>"", "clinic_id"=>1, "network_status"=>"out_of_network", "status"=>"active"},
                        {"id"=>7, "name"=>"New Hampshire BCBS", "plan_name"=>"", "payor_type"=>"commercial", "email"=>"", "notes"=>"", "clinic_id"=>1, "network_status"=>"out_of_network", "status"=>"active"},
                        {"id"=>8, "name"=>"Optumhealth Behavioral Solutions", "plan_name"=>"", "payor_type"=>"commercial", "email"=>"", "notes"=>"", "clinic_id"=>1, "network_status"=>"out_of_network", "status"=>"active"},
                        {"id"=>9, "name"=>"UMR", "plan_name"=>"", "payor_type"=>"commercial", "email"=>"", "notes"=>"", "clinic_id"=>1, "network_status"=>"out_of_network", "status"=>"active"},
                        {"id"=>10, "name"=>"United Behavioral Health", "plan_name"=>"", "payor_type"=>"commercial", "email"=>"", "notes"=>"", "clinic_id"=>1, "network_status"=>"out_of_network", "status"=>"active"},
                        {"id"=>18, "name"=>"Fallon Health", "plan_name"=>"", "payor_type"=>"commercial", "email"=>"", "notes"=>"", "clinic_id"=>1, "network_status"=>"out_of_network", "status"=>"active"},
                        {"id"=>19, "name"=>"Health Plans INC", "plan_name"=>"", "payor_type"=>"commercial", "email"=>"", "notes"=>"", "clinic_id"=>1, "network_status"=>"out_of_network", "status"=>"active"},
                        {"id"=>20, "name"=>"Massachusetts BCBS", "plan_name"=>"", "payor_type"=>"commercial", "email"=>"", "notes"=>"", "clinic_id"=>1, "network_status"=>"out_of_network", "status"=>"active"},
                        {"id"=>21, "name"=>"MBPH (MassHealth)", "plan_name"=>"", "payor_type"=>"medicaid", "email"=>"", "notes"=>"", "clinic_id"=>1, "network_status"=>"out_of_network", "status"=>"active"},
                        {"id"=>22, "name"=>"TUFTS", "plan_name"=>"", "payor_type"=>"commercial", "email"=>"", "notes"=>"", "clinic_id"=>1, "network_status"=>"out_of_network", "status"=>"active"},
                        {"id"=>23, "name"=>"Unicare", "plan_name"=>"", "payor_type"=>"commercial", "email"=>"", "notes"=>"", "clinic_id"=>1, "network_status"=>"out_of_network", "status"=>"active"}] 
      
      funding_sources.each do |funding_source|
        FundingSource.where(id: funding_source['id'], name: funding_source['name'], plan_name: funding_source['plan_name'], payor_type: funding_source['payor_type'], email: funding_source['email'], notes: funding_source['notes'], clinic_id: funding_source['clinic_id'], network_status: funding_source['network_status'], status: funding_source['status']).first_or_create!
      end

      # qualifications
      Qualification.delete_all
      qualifications = [{"id"=>5, "credential_type"=>"education", "name"=>"High School Diploma", "description"=>"The holder has a high school diploma", "lifetime"=>true},
                        {"id"=>8, "credential_type"=>"other", "name"=>"Auto Insurance", "description"=>"Employee's current auto insurance", "lifetime"=>false},
                        {"id"=>14, "credential_type"=>"certification", "name"=>"LABA", "description"=>"", "lifetime"=>false},
                        {"id"=>15, "credential_type"=>"other", "name"=>"BE1", "description"=>"CSE1", "lifetime"=>true},
                        {"id"=>16, "credential_type"=>"certification", "name"=>"RBT", "description"=>"RBT", "lifetime"=>nil},
                        {"id"=>1, "credential_type"=>"education", "name"=>"Bachelor's Degree", "description"=>"Four year college program.", "lifetime"=>true},
                        {"id"=>2, "credential_type"=>"education", "name"=>"Master's Degree", "description"=>"Six year college program.", "lifetime"=>true},
                        {"id"=>3, "credential_type"=>"education", "name"=>"Ph.D.", "description"=>"Doctorate program.", "lifetime"=>true},
                        {"id"=>4, "credential_type"=>"education", "name"=>"Associate's Degree", "description"=>"Associate Dregree", "lifetime"=>true},
                        {"id"=>6, "credential_type"=>"certification", "name"=>"Board Certifield Behavior Analyst", "description"=>"Board certified behavior analyst", "lifetime"=>false},
                        {"id"=>7, "credential_type"=>"certification", "name"=>"Board Certifield Assistant Behavior Analyst", "description"=>"Certified assistant behavior analyst", "lifetime"=>false},
                        {"id"=>9, "credential_type"=>"education", "name"=>"CPR", "description"=>"CPR training", "lifetime"=>false},
                        {"id"=>10, "credential_type"=>"certification", "name"=>"First Aid Certification", "description"=>"First Aid training", "lifetime"=>false},
                        {"id"=>11, "credential_type"=>"certification", "name"=>"30 Day Competency", "description"=>"30 day RBT competency", "lifetime"=>false},
                        {"id"=>12, "credential_type"=>"education", "name"=>"60 Day Competency", "description"=>"60 day RBT competency", "lifetime"=>false},
                        {"id"=>13, "credential_type"=>"education", "name"=>"90 Day Competency", "description"=>"90 day RBT competency", "lifetime"=>false}] 
      qualifications.each do |qualification|
        Qualification.where(id: qualification['id'], credential_type: qualification['credential_type'], name: qualification['name'], description: qualification['description'], lifetime: qualification['lifetime']).first_or_create!
      end

      # roles
      titles = [{"id"=>5, "name"=>"billing", "permissions"=> ["organization_view", "location_view", "location_update", "staff_view", "staff_qualification_view", "staff_qualification_update", "staff_qualification_delete", "staff_location_view", "service_view", "service_update", "funding_source_view", "funding_source_update", "qualification_view", "qualification_update", "clients_view", "clients_update", "client_source_of_payment_view", "client_source_of_payment_update", "client_contacts_view", "client_contacts_update", "client_notes_view", "client_files_view", "client_service_address_view", "client_authorization_view", "client_authorization_update", "schedule_view", "soap_notes_view"]},
                {"id"=>7, "name"=>"client_care_coordinator", "permissions"=> ["staff_view", "staff_update", "staff_qualification_view", "staff_qualification_update", "staff_location_view", "service_view", "funding_source_view", "clients_view", "clients_update", "client_source_of_payment_view", "client_contacts_view", "client_notes_view", "client_notes_update", "client_files_view", "client_files_update", "client_service_address_view", "client_service_address_update", "client_authorization_view", "schedule_view", "schedule_update", "soap_notes_view", "soap_notes_update"]},
                {"id"=>4, "name"=>"rbt", "permissions"=> ["clients_view", "client_source_of_payment_view", "client_contacts_view", "client_contacts_update", "client_service_address_view", "client_service_address_update", "schedule_view", "soap_notes_view", "soap_notes_update", "rbt_signature"]},
                {"id"=>3, "name"=>"bcba", "permissions"=> ["staff_view", "staff_location_view", "clients_view", "clients_update", "client_source_of_payment_view", "client_contacts_view", "client_contacts_update", "client_notes_view", "client_notes_update", "client_files_view", "client_files_update", "client_files_delete", "client_service_address_view", "client_service_address_update", "client_authorization_view", "schedule_view", "schedule_update", "soap_notes_view", "soap_notes_update", "bcba_signature"]},
                {"id"=>1, "name"=>"executive_director", "permissions"=> ["staff_view", "staff_update", "staff_qualification_view", "staff_qualification_update", "staff_location_view", "staff_location_update", "service_view", "funding_source_view", "qualification_view", "clients_view", "clients_update", "client_source_of_payment_view", "client_source_of_payment_update", "client_contacts_view", "client_contacts_update", "client_notes_view", "client_notes_update", "client_files_view", "client_files_update", "client_service_address_view", "client_service_address_update", "client_authorization_view", "client_authorization_update", "schedule_view", "schedule_update", "soap_notes_view", "soap_notes_update", "clinical_director_signature"]},
                {"id"=>8, "name"=>"super_admin", "permissions"=> ["organization_view", "organization_update", "organization_delete", "location_view", "location_update", "location_delete", "staff_view", "staff_update", "staff_delete", "staff_qualification_view", "staff_qualification_update", "staff_qualification_delete", "staff_location_view", "staff_location_update", "staff_location_delete", "service_view", "service_update", "service_delete", "funding_source_view", "funding_source_update", "funding_source_delete", "qualification_view", "qualification_update", "qualification_delete", "clients_view", "clients_update", "clients_delete", "client_source_of_payment_view", "client_source_of_payment_update", "client_source_of_payment_delete", "client_contacts_view", "client_contacts_update", "client_contacts_delete", "client_notes_view", "client_notes_update", "client_notes_delete", "client_files_view", "client_files_update", "client_files_delete", "client_service_address_view", "client_service_address_update", "client_service_address_delete", "client_authorization_view", "client_authorization_update", "client_authorization_delete", "schedule_view", "schedule_update", "schedule_delete", "soap_notes_view", "soap_notes_update", "soap_notes_delete", "roles_view", "roles_update", "roles_delete", "rbt_signature", "bcba_signature", "caregiver_signature", "clinical_director_signature"]},
                {"id"=>2, "name"=>"administrator", "permissions"=>["organization_view", "organization_update", "location_view", "location_update", "staff_view", "staff_update", "staff_qualification_view", "staff_qualification_update", "staff_location_view", "staff_location_update", "service_view", "service_update", "funding_source_view", "funding_source_update", "qualification_view", "qualification_update", "clients_view", "clients_update", "client_source_of_payment_view", "client_source_of_payment_update", "client_source_of_payment_delete", "client_contacts_view", "client_contacts_update", "client_contacts_delete", "client_notes_view", "client_notes_update", "client_notes_delete", "client_files_view", "client_files_update", "client_files_delete", "client_service_address_view", "client_service_address_update", "client_service_address_delete", "client_authorization_view", "client_authorization_update", "client_authorization_delete", "schedule_view", "schedule_update", "schedule_delete", "soap_notes_view", "soap_notes_update", "roles_view"]}]
      titles.each do |title|
        role = Role.find_or_initialize_by(name: title['name'])
        role.permissions = title['permissions']
        role.save(validate: false)
      end
    end
    puts "Production data seed from staging data completed. Thank You!"
  end
end
