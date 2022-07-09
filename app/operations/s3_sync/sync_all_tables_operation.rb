require 'csv'
require 'aws-sdk-s3'
module S3Sync
  module SyncAllTablesOperation
    class << self
      def call
        # return unless Rails.env.production?
        sync_all_tables
      end

      private

      def sync_all_tables
        # sync_data_for Address
        # sync_data_for User
        # sync_data_for Attachment
        # sync_data_for CatalystData
        # sync_data_for ClientEnrollmentServiceProvider
        sync_data_for ClientEnrollmentService
        sync_data_for ClientEnrollment
        # sync_data_for ClientNote
        sync_data_for Client
        # sync_data_for Clinic
        # sync_data_for Contact
        # sync_data_for Country
        # sync_data_for FundingSource
        # sync_data_for Organization
        # sync_data_for PhoneNumber
        # sync_data_for Qualification
        # sync_data_for RbtSupervision
        # sync_data_for Role
        # sync_data_for SchedulingChangeRequest
        sync_data_for Scheduling
        # sync_data_for ServiceQualification
        sync_data_for Service
        # sync_data_for Setting
        # sync_data_for SoapNote
        # sync_data_for StaffClinicService
        # sync_data_for StaffClinic
        # sync_data_for StaffQualification
        # sync_data_for Staff
        # sync_data_for UserRole
      end

      def sync_data_for(model)
        data = to_csv model
        object_name = "#{DateTime.current.to_s(:iso8601)}.csv"
        Dir.mkdir(Rails.root.join('tmp', 'csv_files', model.table_name)) unless File.exists?(Rails.root.join('tmp', 'csv_files', model.table_name))
        File.write(Rails.root.join('tmp', 'csv_files', model.table_name, object_name), data)
        # object_uploaded?(object_name, data) if Rails.env.production?
      end

      def to_csv(model)
        csv = CSV.generate do |csv|
          csv << model.column_names
          model.all.each do |user|
            csv << user.attributes.values_at(*model.column_names)
          end
        end
      end



      def object_uploaded?(object_key, body) 
        bucket_name = Rails.application.credentials.dig(:aws, :bi_bucket) 
        s3_client = Aws::S3::Client.new(
          region: Rails.application.credentials.dig(:aws, :region), 
          access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
          secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key)
        )
        response = s3_client.put_object(
          bucket: bucket_name,
          key: object_key,
          body: body
        )
        if response.etag
          return true
        else
          return false
        end
      rescue StandardError => e
        puts "Error uploading object: #{e.message}"
        return false
      end      
    end
  end
end
