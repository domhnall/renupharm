class Admin::Sales::ContactCommentsController < Admin::CommentsController

  private

  def commentable
    @_commentable = ::Sales::Contact.find(params.fetch(:contact_id).to_i)
  end

  def commentable_path
    admin_sales_contact_path(commentable)
  end
end
