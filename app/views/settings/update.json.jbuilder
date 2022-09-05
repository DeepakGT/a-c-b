json.status @setting.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'welcome_note', setting: @setting
end
json.errors @setting.errors.full_messages
