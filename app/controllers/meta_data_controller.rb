class MetaDataController < ApplicationController
  before_action :authenticate_user!, except: :select_payor_types

  def selectable_options
    @selectable_options = selectable_options_data
  end

  def clinics_list
    if current_user.role_name=='super_admin'
      @clinics = Clinic.order(:name)
    elsif current_user.type=="Staff"
      @clinics = current_user.clinics&.order(:name)
    else
      @clinics = Clinic.where(id: current_user&.clinic_id)&.order(:name)
    end
  end

  def bcba_list
    # bcbas = Staff.joins(:role).by_role('bcba')
    bcbas = Staff.joins(:role).by_roles(['bcba', 'Clinical Director', 'Lead RBT']).active
    # bcbas = bcbas.by_clinic(params[:location_id]) if params[:location_id].present?
    @bcbas = bcbas.order(:first_name, :last_name)
  end

  def rbt_list
    @staff = Staff.active.by_roles('rbt')
  end

  def select_payor_types
    @payor_types = FundingSource.payor_types.keys
  end

  private

  def selectable_options_data
    selectable_options = { countries: country_list,
                           preferred_languages: Client.preferred_languages,
                           dq_reasons: Client.dq_reasons, 
                           relation_types: Contact.relation_types,
                           relations: Contact.relations,
                           credential_types: Qualification.credential_types,
                           roles: Role.where.not(name: 'super_admin'),
                           phone_types: PhoneNumber.phone_types,
                           source_of_payments: ClientEnrollment.source_of_payments }
  end

  def country_list
    countries = Country.order(:name)
    prioritize_country = Country.find_by(name: "United States of America")
    countries = countries.to_a.prepend(prioritize_country)
    countries = countries.uniq
  end

  # end of private
end
