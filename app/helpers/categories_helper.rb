module CategoriesHelper
  def category_select_collection(categories)
    categories.map{ |category| [category.category_name, category.id] }
  end
end
