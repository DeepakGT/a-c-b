module ClientEnrollmentServices
  module UpdateUnitsColumnsOperation
    class << self
      def call(client_enrollment_service)
        update_units_and_minutes_columns(client_enrollment_service)
      end

      private

      def update_units_and_minutes_columns(client_enrollment_service)
        schedules = client_enrollment_service.schedulings.with_rendered_or_scheduled_as_status
        if schedules.any?
          completed_schedules = schedules.completed_scheduling
          scheduled_schedules = schedules.scheduled_scheduling
          used_units = completed_schedules.with_units.pluck(:units).sum
          used_units = 0 if used_units.blank?
          scheduled_units = scheduled_schedules.with_units.pluck(:units).sum
          scheduled_units = 0 if scheduled_units.blank?
          left_units = client_enrollment_service.units.present? ? (client_enrollment_service.units-(used_units+scheduled_units)) : 0

          used_minutes = completed_schedules.with_minutes.pluck(:minutes).sum
          used_minutes = 0 if used_minutes.blank?
          scheduled_minutes = scheduled_schedules.with_minutes.pluck(:minutes).sum
          scheduled_minutes = 0 if scheduled_minutes.blank?
          left_minutes = client_enrollment_service.minutes.present? ? (client_enrollment_service.minutes-(used_minutes+scheduled_minutes)) : 0

          client_enrollment_service.left_units = left_units
          client_enrollment_service.used_units = used_units
          client_enrollment_service.scheduled_units = scheduled_units

          client_enrollment_service.left_minutes = left_minutes
          client_enrollment_service.used_minutes = used_minutes
          client_enrollment_service.scheduled_minutes = scheduled_minutes

          # We are using validate:false because these are just calculations operation. 
          # If there are chances of error, error will occur before this operation is run.
          client_enrollment_service.save(validate: false)
        end
      end
    end
  end
end
