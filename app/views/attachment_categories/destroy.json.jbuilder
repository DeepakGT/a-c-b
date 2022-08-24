json.status @attachment_category.errors.any? ? 'failure' : 'success'
json.data @attachment_category
json.errors @attachment_category.errors.full_messages
