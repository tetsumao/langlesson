require 'rails_helper'

RSpec.describe "periods/index", type: :view do
  before(:each) do
    assign(:periods, [
      Period.create!(),
      Period.create!()
    ])
  end

  it "renders a list of periods" do
    render
  end
end
