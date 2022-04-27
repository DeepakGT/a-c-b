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
                {"id"=>10, "name"=>"South East, FL", "aka"=>"shoutheast", "web"=>nil, "email"=>"sourthfl@abacenters.com", "status"=>"active", "organization_id"=>1, "catalyst_clinic_id"=> nil},
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
    end
    puts "Production data seed from staging data completed. Thank You!"
  end
end
