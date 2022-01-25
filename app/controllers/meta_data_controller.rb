class MetaDataController < ApplicationController
  before_action :authenticate_user!

  def selectable_options
    @countries = country_list
    @payer_statuses = Client.payer_statuses
    @preferred_languages = Client.preferred_languages
    @dq_reasons = Client.dq_reasons
    @relation_types = Contact.relation_types
    @relations = Contact.relations
    @credential_types = Credential.credential_types
    @roles = Role.all
    @phone_types = PhoneNumber.phone_types
  end
end

private

def country_list
  countries = Country.order(:name)
  prioritize_country = Country.find_by(name: "United States of America")
  countries = countries.to_a.prepend(prioritize_country)
  countries = countries.uniq
end
