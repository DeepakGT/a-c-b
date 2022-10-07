class Region < ApplicationRecord
  has_one :clinic
  validates :name, presence: true, length: { minimum: 3, maximum: 50 }
  
  validate :uniques_name

  private
  
  def uniques_name
    return true if Region.where("LOWER(name) = ? ", name.downcase).count == Constant.zero

    errors.add(:name, message: I18n.t('activerecord.models.region.errors.unique_name'))
  end
end
