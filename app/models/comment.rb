class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true, inverse_of: :comments, counter_cache: true
  belongs_to :user

  validates :body, presence: true, length: {maximum: 1000}
end
