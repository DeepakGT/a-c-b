namespace :add_region_permissions do
  desc 'Insert new permissions roles'
  task fill: :environment do
    super_admin = Role.find_by(name: Constant.super_admin)
    super_admin.permissions.push("regions_view", "regions_update", "regions_delete")
    super_admin.save
  end
end
