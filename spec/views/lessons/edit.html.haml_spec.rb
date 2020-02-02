require 'rails_helper'

RSpec.describe "lessons/edit", type: :view do
  before(:each) do
    @lesson = assign(:lesson, Lesson.create!(
      :user => nil,
      :period => nil,
      :category => nil,
      :ticket => nil,
      :zoom_url => "MyString"
    ))
  end

  it "renders the edit lesson form" do
    render

    assert_select "form[action=?][method=?]", lesson_path(@lesson), "post" do

      assert_select "input[name=?]", "lesson[user_id]"

      assert_select "input[name=?]", "lesson[period_id]"

      assert_select "input[name=?]", "lesson[category_id]"

      assert_select "input[name=?]", "lesson[ticket_id]"

      assert_select "input[name=?]", "lesson[zoom_url]"
    end
  end
end
