require 'rails_helper'

RSpec.describe "periods/show", type: :view do
  before(:each) do
    @period = assign(:period, Period.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
