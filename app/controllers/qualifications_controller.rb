class QualificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, except: :types
  before_action :set_qualification, only: %i[show update destroy]

  def index
    @qualifications = Qualification.order(:created_at)
    @qualifications = @qualifications.paginate(page: params[:page]) if params[:page].present?
  end

  def create
    @qualification = Qualification.new(qualification_params)
    @qualification.id = Qualification.ids.max+1
    @qualification.save
  end

  def show
    @qualification
  end

  def update
    @qualification.update(qualification_params)
  end

  def destroy
    @qualification.destroy
  end

  def types
    @types = Qualification.credential_types
  end

  private

  def qualification_params
    params.permit(:credential_type, :name, :description, :lifetime)
  end

  def set_qualification
    @qualification = Qualification.find(params[:id])
  end

  def authorize_user
    authorize Qualification if current_user.role_name!='super_admin'
  end
  # end of private

end
