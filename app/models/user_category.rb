class UserCategory < ApplicationRecord
  belongs_to :user, inverse_of: :user_categories
  belongs_to :category

  validates :category_id, presence: true
end
