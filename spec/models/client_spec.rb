require 'rails_helper'

RSpec.describe Client, type: :model do
  it { should have_one(:phone_number).dependent(:destroy) }
  it { should have_many(:notes).class_name('ClientNote').dependent(:nullify) } 
  it { should have_many(:attachments).dependent(:destroy) }

  it { should have_many(:contacts).dependent(:destroy) } 
  it { should have_many(:addresses).dependent(:destroy) }
  it { should have_many(:client_enrollments).dependent(:destroy) }
  it { should have_many(:funding_sources).through(:client_enrollments) }  

  it { should belong_to(:clinic) } 

  it { should accept_nested_attributes_for(:addresses).update_only(true)}
  it { should accept_nested_attributes_for(:phone_number).update_only(true)}

  it { should define_enum_for(:preferred_language)}
  it { should define_enum_for(:dq_reason)}

  context "if disqualified" do
    before { allow(subject).to receive(:disqualified?).and_return(true) }
    it { should validate_presence_of(:dq_reason) }
  end

  context "if disqualified" do
    before { allow(subject).to receive(:disqualified?).and_return(false) }
    it { should validate_absence_of(:dq_reason) }
  end
end
