class ClientEnrollmentService < ApplicationRecord
  belongs_to :client_enrollment
  belongs_to :service

  has_many :service_providers, class_name: :ClientEnrollmentServiceProvider, dependent: :destroy
  has_many :staff, through: :service_providers
  has_many :schedulings, dependent: :destroy

  accepts_nested_attributes_for :service_providers

  validate :validate_service_providers
  # validate :validate_units_and_minutes
  validate :validate_count_of_units, on: :update
  validate :validate_dates

  before_validation :set_units_and_minutes

  scope :by_client, ->(client_ids){ joins(:client_enrollment).where('client_enrollments.client_id': client_ids) }
  scope :by_date, ->(date){ where('start_date <= ? AND end_date >= ?', date, date) }
  scope :by_staff, ->(staff_id){ joins(:service_providers).where('client_enrollment_service_providers.staff_id': staff_id) }
  scope :by_service, ->(service_ids){ where(service_id: service_ids) }
  scope :by_staff_qualifications, ->(staff_qualification_ids) { where('service_qualifications.qualification_id': staff_qualification_ids) }
  scope :by_service_with_no_qualification, ->{select("client_enrollment_services.*").group("client_enrollment_services.id").having("count(service_qualifications.*) = ?",0)}
  scope :by_bcba_ids, ->(bcba_ids){ joins(client_enrollment: :client).where('clients.bcba_id': bcba_ids) }
  scope :about_to_expire, ->{ where('end_date>=? AND end_date<=?', Time.current.to_date, (Time.current.to_date+9)) }
  scope :by_client_enrollment, ->(client_enrollment_id){ where(client_enrollment_id: client_enrollment_id)}
  scope :by_funding_source, ->(funding_source_id){ where('client_enrollments.funding_source_id': funding_source_id) }
  scope :expire_in_5_days, ->{ where('end_date >= ? AND end_date<=?', Time.current.to_date, (Time.current.to_date+4))}
  scope :started_between_5_to_20_days_past_from_today, ->{ where('start_date>=? AND start_date<=?', (Time.current - 20.days).strftime('%Y-%m-%d'), (Time.current - 5.days).strftime('%Y-%m-%d')) }
  scope :started_between_21_to_60_days_past_from_today, ->{ where('start_date>=? AND start_date<=?', (Time.current - 60.days).strftime('%Y-%m-%d'), (Time.current - 21.days).strftime('%Y-%m-%d')) }
  scope :except_self, ->(self_id){ where.not(id: self_id) }
  scope :active, ->{ where('end_date >= ?', Time.current.strftime('%Y-%m-%d')) }
  scope :before_date, ->(date){ where('start_date < ?', date.to_time.strftime('%Y-%m-%d')) }

  private

  def validate_service_providers
    errors.add(:service_providers, 'must be absent.') if self.service.is_service_provider_required.to_bool.false? && self.service_providers.present?
    errors.add(:service_providers, 'must be present.') if self.service.is_service_provider_required.to_bool.true? && self.service_providers.blank?
  end

  # def validate_units_and_minutes
  #   if self.units.present? && self.minutes.present?
  #     minutes = self.units*15
  #     errors.add(:client_enrollment_service, "The units/minutes are wrong. 1 unit is equivalent to 15 minutes, and vice versa.") if minutes != self.minutes
  #   end
  # end

  def set_units_and_minutes
    if self.units.present? && self.minutes.blank?
      self.minutes = self.units*15
    elsif self.minutes.present? && self.units.blank?
      # self.units = self.minutes/15
      rem = self.minutes%15
      if rem == 0
        self.units = self.minutes/15
      else
        if rem < 8
          self.units = (self.minutes - rem)/15
        else
          self.units = (self.minutes + 15 - rem)/15
        end
      end 
    end
  end

  def validate_count_of_units
    scheduled_units = self.schedulings&.by_status&.with_units&.pluck(:units)&.sum
    if scheduled_units>0 && self.units < scheduled_units
      errors.add(:units, "Units entered in client_enrollment service are less than #{scheduled_units} units used in schedulings.")
    end
  end

  def validate_dates
    client_enrollment_services = ClientEnrollmentService.by_client_enrollment(self.client_enrollment_id)
                                                        .by_service(self.service_id)
                                                        .where.not(id: self.id)
    client_enrollment_services = client_enrollment_services.where('start_date <= ? AND end_date >= ?', self.start_date, self.start_date)
                                                           .or(client_enrollment_services.where('start_date >= ? AND start_date <= ?', self.start_date, self.end_date))
    if client_enrollment_services.any?
      errors.add(:client_enrollment_service, 'cannot be created for given start date and end date.')
    end
  end
  # end of private
end
