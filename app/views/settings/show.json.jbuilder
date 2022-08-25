json.status 'success'
json.data do
  json.partial! 'welcome_note', setting: setting
end
