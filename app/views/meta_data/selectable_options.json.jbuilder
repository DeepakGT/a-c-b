json.status 'success'
json.data do
  json.payer_statuses do
    json.array! @selectable_options[:payer_statuses] do |payer_status|
      json.id payer_status.last
      json.type payer_status.first
    end
  end
  json.preferred_languages do
    json.array! @selectable_options[:preferred_languages] do |preferred_language|
      json.id preferred_language.last
      json.type preferred_language.first
    end
  end
  json.dq_reasons do
    json.array! @selectable_options[:dq_reasons] do |dq_reason|
      json.id dq_reason.last
      json.type dq_reason.first
    end
  end
  json.relation_types do
    json.array! @selectable_options[:relation_types] do |relation_type|
      json.id relation_type.last
      json.type relation_type.first
    end
  end
  json.relations do
    json.array! @selectable_options[:relations] do |relation|
      json.id relation.last
      json.type relation.first
    end
  end
  json.credential_types do
    json.array! @selectable_options[:credential_types] do |type|
      json.id type.last
      json.type type.first
    end
  end
  json.roles do
    json.array! @selectable_options[:roles] do |role|
      json.id role.id
      json.name role.name
    end
  end
  json.phone_types do
    json.array! @selectable_options[:phone_types] do |phone_type|
      json.id phone_type.last
      json.type phone_type.first
    end
  end
  json.country_list do
    json.array! @selectable_options[:countries] do |country|
      json.id country.id
      json.name country.name
    end
  end
end
