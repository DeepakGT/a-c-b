namespace :add_gender_staff do
  desc 'add gender staff'
  task add_gender: :environment do
    genders = ['male', 'female', 'non_binary']

    User.find_in_batches(batch_size: Constant.limit) do |group|
      group.each do |user|
        puts "user #{user.first_name}"
        user.update gender: genders[user.gender_tmp]
      end
    end
  end
end