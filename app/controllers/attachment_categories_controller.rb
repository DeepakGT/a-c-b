class AttachmentCategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_attachment_category, only: %i[show update destroy]


  def index
    @attachment_categories = AttachmentCategory.all.sort_by(&:id)
  end

  def show
    @attachment_category
  end

  def create
    @attachment_category = AttachmentCategory.create(attachment_category_params)

    if @attachment_category.valid?
      @attachment_category
    else
      render json: {status: :failed, error: @attachment_category.errors.full_messages}, status: 422
    end
  end

  def update
    @attachment_category.update(attachment_category_params)
    
    if @attachment_category.valid?
      @attachment_category
    else
      render json: {status: :failed, error: @attachment_category.errors.full_messages}, status: 422
    end
  end

  def destroy
    @attachment_category.destroy
  end

  private


  def set_attachment_category
    @attachment_category = AttachmentCategory.find(params[:id])
  end

  def attachment_category_params
    params.permit(:name)
  end
end
