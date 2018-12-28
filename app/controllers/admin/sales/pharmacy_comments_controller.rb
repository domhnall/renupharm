class Admin::Sales::PharmacyCommentsController < Admin::CommentsController

  private

  def commentable
    @_commentable = ::Sales::Pharmacy.find(params.fetch(:pharmacy_id).to_i)
  end

  def commentable_path
    admin_sales_pharmacy_path(commentable)
  end
end
