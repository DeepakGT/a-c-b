namespace :remove_draft_appointment do
  desc 'eliminate appointment drafts'
  task remove: :environment do
    Scheduling.where(status: 'draft', date: ..Date.today).each do |scheduling_draft|
      scheduled_draft = Scheduling.find_by(id: scheduling_draft.id)
      scheduled_draft.destroy if scheduled_draft.date < Date.today
    end
  end
end
