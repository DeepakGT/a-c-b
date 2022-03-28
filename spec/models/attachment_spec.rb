require 'rails_helper'

RSpec.describe Attachment, type: :model do
  it { should belong_to(:attachable) }
  it { should have_one_attached(:file) }

  it { is_expected.to callback(:set_file).before(:save) }
  it { is_expected.to callback(:set_storage).before(:save) }

  it { should validate_presence_of(:file_name) }
end
