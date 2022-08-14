class ApplicationConfig < ApplicationRecord
  validates :config_key, presence: true
  validates_uniqueness_of :config_key
end
