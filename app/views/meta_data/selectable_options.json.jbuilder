json.status 'success'
json.data do
  json.preferred_languages do
    json.partial! 'list_detail_with_type', list: @selectable_options[:preferred_languages]
  end
  json.dq_reasons do
    json.partial! 'list_detail_with_type', list: @selectable_options[:dq_reasons]
  end
  json.relation_types do
    json.partial! 'list_detail_with_type', list: @selectable_options[:relation_types]
  end
  json.relations do
    json.partial! 'list_detail_with_type', list: @selectable_options[:relations]
  end
  json.credential_types do
    json.partial! 'list_detail_with_type', list: @selectable_options[:credential_types]
  end
  json.roles do
    json.partial! 'list_detail_with_name', list: @selectable_options[:roles]
  end
  json.phone_types do
    json.partial! 'list_detail_with_type', list: @selectable_options[:phone_types]
  end
  json.country_list do
    json.partial! 'list_detail_with_name', list: @selectable_options[:countries]
  end
  json.source_of_payments do
    json.partial! 'list_detail_with_type', list: @selectable_options[:source_of_payments]
  end
end
