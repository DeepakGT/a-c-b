module Snowflake
  module SeedStaffDataOperation
    class << self
      def call(username, password)
        seed_staff_data(username, password)
      end

      private

      def seed_staff_data(username, password)
        db = Snowflake::SetDatabaseAndWarehouseService.call(username, password)
        staff_rosters = Snowflake::GetStaffRosterDataService.call(db)

        staff_rosters.each do |staff_roster|
          staff_roster = staff_roster.with_indifferent_access
          staff_count = Staff.all.count
          if staff_roster['email'].blank?
            staff_roster.update(email: "staff_#{staff_count}_user@yopmail.com") if staff_roster['email'].blank?
          end
          if Staff.where(email: staff_roster['email']).blank?
            staff = Staff.find_or_initialize_by(email: staff_roster['email'], dob: staff_roster['dob']&.to_time&.strftime('%Y:%m:%d'), hired_at: staff_roster['hireddate']&.to_time&.strftime('%Y:%m:%d'), first_name: staff_roster['stafffirstname'], last_name: staff_roster['stafflastname'], terminated_on: staff_roster['terminateddate']&.to_time&.strftime('%Y:%m:%d'))
            staff.status = staff_roster['active']=='ACTIVE' ? 'active' : 'inactive'
            staff.gender = staff_roster['gender']=='Female' ? 'female' : 'male'
            staff.job_type = staff_roster['partfulltime']=='Full Time' ? 'full_time' : 'part_time'
            case staff_roster['jobtitle']
            when 'RBT' || 'Lead RBT '
              staff.role = Role.find_or_create_by!(name: 'rbt')
            when 'BCBA'
              staff.role = Role.find_or_create_by!(name: 'bcba')
            when 'Executive Director'
              staff.role = Role.find_or_create_by!(name: 'executive_director')
            else
              staff.role = Role.find_or_create_by!(name: staff_roster['jobtitle']&.downcase)
            end
            staff.save(validate: false)

            if staff_roster['agencyname'].present?
              clinic_name = staff_roster['agencyname']&.downcase
              clinic = Clinic.where('lower(name) = ? OR lower(aka) = ?', clinic_name, clinic_name)&.first
              if clinic.present?
                staff_clinic = staff.staff_clinics.new(clinic_id: clinic.id, is_home_clinic: true)
                staff_clinic.save(validate: false)
              end
            end

            address = Address.find_or_initialize_by(addressable_id: staff.id, addressable_type: 'User')
            address.city = staff_roster['city']
            address.state = staff_roster['state']
            address.zipcode = staff_roster['zip']
            address.save(validate: false)

            phone_number_array = []
            phone_number_array.push(staff_roster['phone1']) if staff_roster['PHONE1'].present?
            phone_number_array.push(staff_roster['phone2']) if staff_roster['PHONE2'].present?
            phone_number_array.push(staff_roster['phone3']) if staff_roster['PHONE3'].present?
            phone_number_array.push(staff_roster['phone4']) if staff_roster['PHONE4'].present?
            if phone_number_array.present?
              phone_number_array.each do |phone_number|
                phone_type_number = phone_number.split(' ')
                staff_phone_number = staff.phone_numbers.new 
                case phone_type_number.first
                when 'Mobile'
                  staff_phone_number.phone_type = 'mobile'
                  staff_phone_number.number = phone_type_number.count<=2 ? phone_type_number.last : "#{phone_type_number[1]} #{phone_type_number[2]}"
                when 'Home'
                  staff_phone_number.phone_type = 'home'
                  staff_phone_number.number = phone_type_number.count<=2 ? phone_type_number.last : "#{phone_type_number[1]} #{phone_type_number[2]}"
                when 'Work'
                  staff_phone_number.phone_type = 'work'
                  staff_phone_number.number = phone_type_number.count<=2 ? phone_type_number.last : "#{phone_type_number[1]} #{phone_type_number[2]}"
                else
                  staff_phone_number.phone_type = 'other'
                  staff_phone_number.number = phone_number
                end
                staff_phone_number.save(validate: false)
              end
            end
          end
        end
      end
    end
  end
end
