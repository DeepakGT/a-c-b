namespace :remove_draft_appointment do
  desc 'remove draft appointments'
  task remove: :environment do
    Scheduling.where(status: 'draft', date: ..Date.today + Constant.third.days).each do |scheduling_draft|
      scheduled_draft = Scheduling.find_by(id: scheduling_draft.id)
      scheduled_draft.destroy
    end
  end
end
