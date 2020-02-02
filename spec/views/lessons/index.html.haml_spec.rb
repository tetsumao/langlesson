require 'rails_helper'

RSpec.describe "lessons/index", type: :view do
  before(:each) do
    assign(:lessons, [
      Lesson.create!(
        :user => nil,
        :period => nil,
        :category => nil,
        :ticket => nil,
        :zoom_url => "Zoom Url"
      ),
      Lesson.create!(
        :user => nil,
        :period => nil,
        :category => nil,
        :ticket => nil,
        :zoom_url => "Zoom Url"
      )
    ])
  end

  it "renders a list of lessons" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Zoom Url".to_s, :count => 2
  end
end
