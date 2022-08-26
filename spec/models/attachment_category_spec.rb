require 'rails_helper'

RSpec.describe AttachmentCategory, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'relationships' do
    it { is_expected.to have_many(:attachments) }
  end
end
