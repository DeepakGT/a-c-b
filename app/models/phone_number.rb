class PhoneNumber < ApplicationRecord

  belongs_to :phoneable, polymorphic: true, inverse_of: :phoneable
  
  enum phone_type: {fax: 0, home: 1, mobile: 2, pager: 3, work: 4, other: 5}

end
