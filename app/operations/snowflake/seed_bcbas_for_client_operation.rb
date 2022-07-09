module Snowflake
  module SeedBcbasForClientOperation
    class << self
      def call(username, password)
        seed_bcbca_id_for_client(username, password)
      end

      private

      def seed_bcbca_id_for_client(username, password)
        db = Snowflake::SetDatabaseAndWarehouseService.call(username, password)
        bcba_clients = Snowflake::GetBcbaClientsDataService.call(db)

        bcba_clients.each do |bcba_client|
          bcba_client = bcba_client.with_indifferent_access
          if bcba_client['empname'].present?
            staff_name = bcba_client['empname'].split(',').each(&:strip!)
            staff = Staff.by_roles('bcba').find_by(first_name: staff_name.last, last_name: staff_name.first)
            if staff.present?
              client = Client.find_by(first_name: bcba_client['firstname'], last_name: bcba_client['lastname'])
              if client.present?
                client.bcba_id = staff.id
                client.save(validate: false)
              end
            end
          end
        end
      end
    end
  end
end
