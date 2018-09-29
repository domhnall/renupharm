class Admin::Sales::CommentsController < Admin::BaseController
  layout :none

  def create
    @comment = commentable.comments.build(comment_params.merge(user: current_user))
    if @comment.save
      redirect_to commentable_path
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessible_entity
    end
  end

  def update
    @comment = current_user.comments.find(params.fetch(:id))
    if @comment.update_attributes(comment_params)
      redirect_to commentable_path
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessible_entity
    end
  end

  def destroy
    @comment = current_user.comments.find(params.fetch(:id))
    @comment.destroy
    redirect_to commentable_path
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

  def commentable
    @_commentable ||= if params[:pharmacy_id].present?
      Sales::Pharmacy.find(params.fetch(:pharmacy_id).to_i)
    elsif params[:contact_id].present?
      Sales::Contact.find(params.fetch(:contact_id).to_i)
    end
  end

  def commentable_path
    case commentable
    when Sales::Pharmacy
      admin_sales_pharmacy_path(commentable)
    when Sales::Contact
      admin_sales_contact_path(commentable)
    end
  end
end
