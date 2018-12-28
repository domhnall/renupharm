class Admin::CommentsController < Admin::BaseController
  layout :none

  def create
    @comment = commentable.comments.build(comment_params.merge(user: current_user))
    if @comment.save
      redirect_to commentable_path, flash: { success: I18n.t("comment.flash.create_successful") }
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessible_entity
    end
  end

  def update
    @comment = current_user.comments.find(params.fetch(:id))
    if @comment.update_attributes(comment_params)
      redirect_to commentable_path, flash: { success: I18n.t("comment.flash.update_successful") }
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessible_entity
    end
  end

  def destroy
    @comment = current_user.comments.find(params.fetch(:id))
    @comment.destroy
    redirect_to commentable_path, flash: { success: I18n.t("comment.flash.delete_successful") }
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

  def commentable
    raise NotImplementedError, "This should be implemented in a subclassed controller"
  end

  def commentable_path
    raise NotImplementedError, "This should be implemented in a subclassed controller"
  end
end
