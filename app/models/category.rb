class Category < ApplicationRecord
  after_initialize :initialize_dspo

  has_many :user_categories, dependent: :destroy
  has_many :users, through: :user_categories, source: :user
  has_many :lessons

  private
    def initialize_dspo
      if self.dspo.nil?
        max = Category.maximum(:dspo)
        self.dspo = max.nil? ? 1 : (max + 1)
      end
    end
end
