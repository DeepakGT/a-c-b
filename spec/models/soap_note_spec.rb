require 'rails_helper'

RSpec.describe SoapNote, type: :model do
  describe "#associations" do
    it { SoapNote.reflect_on_association(:scheduling).macro.should eq(:belongs_to) }
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

  describe "#validate_signatures" do
    let!(:staff1){ create(:staff, :with_role, role_name: 'bcba') }
    let!(:staff2){ create(:staff, :with_role, role_name: 'rbt') }
    let!(:staff3){ create(:staff, :with_role, role_name: 'bcba') }
    let!(:staff4){ create(:staff, :with_role, role_name: 'rbt') }
    context "when appointment is created for bcba" do
      let(:client_enrollment_service){ create(:client_enrollment_service, service_providers_attributes: [{staff_id: staff1.id}])}
      let(:scheduling){ create(:scheduling, staff_id: staff1.id) }
      context "when logged in user is rbt" do
        let(:soap_note){ build :soap_note, scheduling_id: scheduling.id, rbt_signature: true, rbt_signature_author_name: "#{staff2.first_name} #{staff2.last_name}", user: staff2}
        it "should not allow to sign" do
          soap_note.validate
          expect(soap_note.errors[:rbt_signature]).to include('must not be present for appointment created for bcba.')
        end
      end

      context "when logged in user is bcba who is not in authorization" do
        let(:soap_note){ build :soap_note, scheduling_id: scheduling.id, bcba_signature: true, bcba_signature_author_name: "#{staff3.first_name} #{staff3.last_name}", user: staff3}
        it "should not allow to sign" do
          soap_note.validate
          expect(soap_note.errors[:bcba_signature]).to include('cannot be done by bcba that is not in authorization.')
        end
      end
    end

    context "when appointment is created for rbt" do
      let(:client_enrollment_service){ create(:client_enrollment_service, service_providers_attributes: [{staff_id: staff1.id}])}
      let(:scheduling){ create(:scheduling, staff_id: staff2.id) }
      context "when logged in user is rbt that is not in appointment" do
        let(:soap_note){ build :soap_note, scheduling_id: scheduling.id, rbt_signature: true, rbt_signature_author_name: "#{staff4.first_name} #{staff4.last_name}", user: staff4}
        it "should not allow to sign" do
          soap_note.validate
          expect(soap_note.errors[:rbt_signature]).to include('cannot be done by rbt that is not in appointment. Please update appointment to let another rbt sign.')
        end
      end

      context "when logged in user is bcba and tries to add rbt_signature" do
        let(:soap_note){ build :soap_note, scheduling_id: scheduling.id, rbt_signature: true, rbt_signature_author_name: "#{staff3.first_name} #{staff3.last_name}", user: staff3}
        it "should not allow to sign" do
          soap_note.validate
          expect(soap_note.errors[:rbt_signature]).to include('cannot be done by bcba.')
        end
      end
    end

    context "when another role tries to sign" do
      let!(:staff) {create(:staff, :with_role, role_name: 'billing')}
      context "as a bcba" do
        let(:soap_note){ build :soap_note, bcba_signature: true, bcba_signature_author_name: "#{staff.first_name} #{staff.last_name}", user: staff}
        it "should not allow to sign as bcba" do
          soap_note.validate
          expect(soap_note.errors[:bcba_signature]).to include('You are not authorized to sign as a bcba.')
        end
      end

      context "as a rbt" do
        let(:soap_note){ build :soap_note, rbt_signature: true, rbt_signature_author_name: "#{staff.first_name} #{staff.last_name}", user: staff}
        it "should not allow to sign as rbt" do
          soap_note.validate
          expect(soap_note.errors[:rbt_signature]).to include('You are not authorized to sign as a rbt.')
        end
      end

      context "as a clinical director" do
        let(:soap_note){ build :soap_note, clinical_director_signature: true, clinical_director_signature_author_name: "#{staff.first_name} #{staff.last_name}", user: staff}
        it "should not allow to sign as clinical director" do
          soap_note.validate
          expect(soap_note.errors[:clinical_director_signature]).to include('You are not authorized to sign as a clinical director.')
        end
      end
    end
  end
end
