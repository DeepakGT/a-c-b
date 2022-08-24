require 'rails_helper'

RSpec.describe AttachmentCategory, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'relationships' do
    it { should have_many(:attachments) }
  end
end
