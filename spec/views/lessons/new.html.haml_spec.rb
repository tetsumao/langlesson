require 'rails_helper'

RSpec.describe "lessons/new", type: :view do
  before(:each) do
    assign(:lesson, Lesson.new(
      :user => nil,
      :period => nil,
      :category => nil,
      :ticket => nil,
      :zoom_url => "MyString"
    ))
  end

  it "renders new lesson form" do
    render

    assert_select "form[action=?][method=?]", lessons_path, "post" do

      assert_select "input[name=?]", "lesson[user_id]"

      assert_select "input[name=?]", "lesson[period_id]"

      assert_select "input[name=?]", "lesson[category_id]"

      assert_select "input[name=?]", "lesson[ticket_id]"

      assert_select "input[name=?]", "lesson[zoom_url]"
    end
  end
end
