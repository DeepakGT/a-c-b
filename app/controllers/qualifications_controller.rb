class QualificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, except: :types
  before_action :set_qualification, only: %i[show update]

  def index
    # if page parameter would be pass then return paginated records otherwise return all records
    @qualifications = Qualification.order(:created_at)
    @qualifications = @qualifications.paginate(page: params[:page]) if params[:page].present?
  end

  def create
    @qualification = Qualification.create(qualification_params)
  end

  def show; end

  def update
    @qualification.update(qualification_params)
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
