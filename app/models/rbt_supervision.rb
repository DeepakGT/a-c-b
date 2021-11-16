class RbtSupervision < ApplicationRecord
  belongs_to :user

  enum status: {requires: 0, provides: 1, n_a: 2}
end
