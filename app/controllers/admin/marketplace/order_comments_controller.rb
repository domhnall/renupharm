class Admin::Marketplace::OrderCommentsController < Admin::CommentsController

  private

  def commentable
    @_commentable ||= ::Marketplace::Order.find(params.fetch(:order_id).to_i)
  end

  def commentable_path
    admin_marketplace_order_path(commentable)
  end
end
