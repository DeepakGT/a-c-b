class CredentialsController < ApplicationController
  before_action :authenticate_user!
  # before_action :authorize_user, except: :types
  before_action :set_credential, only: %i[show update]

  def index
    # if page parameter would be pass then return paginated records otherwise return all records
    @credentials = Credential.all
    @credentials = @credentials.paginate(page: params[:page]) if params[:page].present?
  end

  def create
    @credential = Credential.create(credential_params)
  end

  def show; end

  def update
    @credential.update(credential_params)
  end

  def types
    @types = Credential.credential_types
  end

  private

  def credential_params
    params.permit(:credential_type, :name, :description, :lifetime)
  end

  def set_credential
    @credential = Credential.find(params[:id])
  end

  def authorize_user
    authorize Credential if current_user.role_name!='super_admin'
  end
  # end of private

end
