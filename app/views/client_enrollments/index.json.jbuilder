json.status 'success'
json.data do
  json.array! @client_enrollments do |client_enrollment|
    json.partial! 'client_enrollment_detail', client_enrollment: client_enrollment
    json.services do
      if params[:show_expired_before_30_days].to_bool.true?
        client_enrollment_services = client_enrollment.client_enrollment_services
      else
        client_enrollment_services = client_enrollment.client_enrollment_services.not_expired_before_30_days
      end
      json.array! client_enrollment_services do |enrollment_service|
        json.partial! '/client_enrollment_services/client_enrollment_service_detail', enrollment_service: enrollment_service
      end
    end
  end
end
non_billable_funding_sources = FundingSource.where(network_status: 'non_billable')
if non_billable_funding_sources.present?
  json.nonBillabelPayorExists true
else
  json.nonBillabelPayorExists false
end
if ((@client&.non_early_authorizations_except_97151&.present? || !@client&.authorization_includes_97151&.present? ) || (@client&.early_authorizations&.present? && @client&.funding_source_ids&.count==FundingSource.non_billable_funding_sources.count)) || @client&.days_since_creation>180
  json.hideEarlyAuthButton true
else
  json.hideEarlyAuthButton false
end
json.partial! '/pagination_detail', list: @client_enrollments, page_number: params[:page]
