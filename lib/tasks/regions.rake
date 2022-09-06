namespace :regions do
  desc 'create insert in the model region'
  task fill: :environment do
    regions = %w[North South West East Atlantic]

    regions.each do |r|
      Region.create name: r
    end
  end
end
