namespace :permission_draft_appointment do
  desc 'add permission to appoinment draft only roles to Super Admin, CC and CD'
  task add_permission: :environment do
    role_ccc
    role_cd
    role_super_admin
  end

  def role_ccc
    find(Constant.roles['ccc'])
  end

  def role_cd
    find(Constant.roles['cd'])
  end

  def role_super_admin
    find(Constant.roles['super_admin'])
  end

  def find(role_name)
    puts "find role #{role_name}"
    role = Role.find_by_name(role_name)
    add_permission = role.permissions
    add_permission.push('schedule_draft')
    role.update(permissions: add_permission)
  end
end
