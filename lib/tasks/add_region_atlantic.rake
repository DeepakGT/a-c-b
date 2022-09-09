namespace :add_region_atlantic do
  desc 'insert atlantic in the model region'
  task fill: :environment do
    Region.create name: 'atlantic'
  end
end
