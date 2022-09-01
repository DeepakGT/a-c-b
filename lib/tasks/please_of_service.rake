namespace :please_of_service do
  desc 'create insert old address_name -> aka'
  puts "begin"
  task fill: :environment do
    please_of_services = Address.where(address_type: "service_address")
    akas = ["School", "Office", "Home", "Community"]
    please_of_services.each {|please_of_service| puts "please_of_services #{please_of_service.address_name.upcase_first} - #{akas.select {|aka| aka == please_of_service.address_name.upcase_first}}"}
  end
end
