class Notification < ApplicationRecord
  include Noticed::Model

  belongs_to :recipient, polymorphic: true

  scope :by_ids, ->(ids) { where(id:ids).order(created_at: :desc) }
end
