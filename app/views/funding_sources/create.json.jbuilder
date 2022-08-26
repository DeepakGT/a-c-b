json.status @funding_source.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'funding_source_detail', funding_source: @funding_source
end
json.errors @funding_source.errors.full_messages&.map{|x| x.gsub!('Address ', '')}
