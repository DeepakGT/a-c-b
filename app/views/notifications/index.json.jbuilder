json.status 'success'
json.data do
  json.array! @notifications do |notification|
    json.partial! 'notification_detail', notification: notification
  end
end
json.partial! '/pagination_detail', list: @notifications, page_number: params[:page]
