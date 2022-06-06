namespace :update_catalyst_data do
    desc "Update Location and Session Location for existing catalyst data"
    task update_location_and_session_location: :environment do
      data = CatalystData.all
      data.each do |d|
        response = d.response["responses"]
        location = response.select {|res| res["questionText"] == "Location" && res["type"] == "Location"}.first
        loc = location.present? ? location["answer"] : ""
        session_location = response.select {|res| res["questionText"] == "Session Location" && res["type"] == "StaticList"}.first
        session_loc = session_location.present? ? session_location["answer"] : ""
        d.location = loc
        d.session_location = session_loc
        d.save
      end
    end
  end
  