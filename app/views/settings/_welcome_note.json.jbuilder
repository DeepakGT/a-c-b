json.id setting&.id
json.welcome_note setting&.welcome_note
json.roles_ids setting&.roles_ids
json.roles_names Role.where(id: setting&.roles_ids).pluck(:name)
