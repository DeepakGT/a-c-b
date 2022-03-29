class PhoneNumber < ApplicationRecord
  belongs_to :phoneable, polymorphic: true
  
  enum phone_type: {mobile: 0, home: 1, work: 2, other: 3}

  after_initialize :set_default_phone_type

  private

  def set_default_phone_type
    self.phone_type ||= 'mobile' 
  end
  # end of private
end
