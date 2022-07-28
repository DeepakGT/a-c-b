json.status 'success'
json.data do
  json.array! @clients do |client|
    primary_client_enrollment = client.client_enrollments.active.order(is_primary: :desc).first
    json.partial! 'client_detail', client: client
    if primary_client_enrollment.present?
      if primary_client_enrollment.source_of_payment=='self_pay' || primary_client_enrollment.funding_source.blank?
        json.payor nil
      else
        json.payor primary_client_enrollment.funding_source.name
      end
    end
  end
end
json.show_inactive params[:show_inactive] if (params[:show_inactive] == 1 || params[:show_inactive] == "1")
json.search_cross_location params[:search_cross_location] if (params[:search_cross_location] == 1 || params[:search_cross_location] == "1")
if params[:page].present?
  json.total_records @clients.total_entries
  json.limit @clients.per_page
  json.page params[:page]
end
