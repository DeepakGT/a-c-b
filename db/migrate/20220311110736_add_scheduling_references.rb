class AddSchedulingReferences < ActiveRecord::Migration[6.1]
  class Scheduling < ApplicationRecord; end

  def up
    add_reference :schedulings, :client_enrollment_service, foreign_key: true, index: true
    update_scheduling_data
  end

  def down 
    remove_reference :schedulings, :client_enrollment_service, foreign_key: true, index: true
  end

  private

  def update_scheduling_data
    Scheduling.all.each do |schedule|
      schedule.update(client_enrollment_service_id: ClientEnrollmentService.by_client(schedule.client_id).by_service(schedule.service_id)&.first&.id)
    end
  end
end
