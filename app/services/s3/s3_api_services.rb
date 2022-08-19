require 'aws-sdk-s3'

module S3
  module S3ApiServices
    class << self
      def get_s3_client
        Aws::S3::Client.new(
          region: Rails.application.credentials.dig(:aws, :region),
          access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
          secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key)
        )
      end

      def get_file(s3_client, bucket_name, file_name)
        resp = s3_client.get_object({ bucket: bucket_name, key: file_name })
        resp.body.read
      end

      def put_file(s3_client, bucket_name, file_name, data)
        s3_client.put_object({ bucket: bucket_name, key: file_name, body: data })
      end
    end
  end
end



