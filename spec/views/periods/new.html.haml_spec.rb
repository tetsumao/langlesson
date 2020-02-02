require 'rails_helper'

RSpec.describe "periods/new", type: :view do
  before(:each) do
    assign(:period, Period.new())
  end

  it "renders new period form" do
    render

    assert_select "form[action=?][method=?]", periods_path, "post" do
    end
  end
end
