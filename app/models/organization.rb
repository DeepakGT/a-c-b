class Organization < ApplicationRecord
  # associations
  belongs_to :admin, class_name: 'User'

  has_one :address, as: :addressable, dependent: :destroy, inverse_of: :addressable
  has_one :phone_number, as: :phoneable, dependent: :destroy, inverse_of: :phoneable
  has_many :clinics, dependent: :destroy

  accepts_nested_attributes_for :address, update_only: true
  accepts_nested_attributes_for :phone_number, update_only: true

  enum status: {active: 0, inactive: 1}

  validates :name, presence: true
  validates_uniqueness_of :name

  def regions
    id_regions.map {|id_region| Region.find_by(id: id_region) }
  end

  def region_locations(region_id, organization_id)
    Clinic.where(region_id: region_id, organization_id: organization_id).map { |location| {id: location.id, name: location.name} }
  end

  def delete_region(region_id)
    locations = region_locations(region_id, id)
    return { organization: self, locations: locations } if locations.present?

    update(id_regions: id_regions.delete_if { |id_region| id_region == region_id})
    { organization: self, locations: Constant.void_a }
  end
end
