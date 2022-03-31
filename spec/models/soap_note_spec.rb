require 'rails_helper'

RSpec.describe SoapNote, type: :model do
  describe "#associations" do
    it { SoapNote.reflect_on_association(:scheduling).macro.should  eq(:belongs_to) }
    it { should have_one_attached(:signature_file) }
  end

  describe "#callbacks" do
    it { is_expected.to callback(:set_signature_file).before(:save) }
    it { is_expected.to callback(:set_storage).before(:save) }
  end
  
  describe "#attr_accessor" do
    let(:soap_note){build :soap_note}
    RSpec::Matchers.define :have_attr_accessor do |user|
      match do |soap_note|
        soap_note.respond_to?(user) &&
          soap_note.respond_to?("#{user}=")
      end
    
      failure_message_for_should do |soap_note|
        "expected attr_accessor for #{user} on #{soap_note}"
      end
    
      failure_message_for_should_not do |soap_note|
        "expected attr_accessor for #{user} not to be defined on #{soap_note}"
      end
    
      description do
        "checks to see if there is an attr accessor on the supplied object"
      end
    end

    RSpec::Matchers.define :have_attr_accessor do |caregiver_sign|
      match do |soap_note|
        soap_note.respond_to?(caregiver_sign) &&
          soap_note.respond_to?("#{caregiver_sign}=")
      end
    
      failure_message_for_should do |soap_note|
        "expected attr_accessor for #{caregiver_sign} on #{soap_note}"
      end
    
      failure_message_for_should_not do |soap_note|
        "expected attr_accessor for #{caregiver_sign} not to be defined on #{soap_note}"
      end
    
      description do
        "checks to see if there is an attr accessor on the supplied object"
      end
    end
  end
end
