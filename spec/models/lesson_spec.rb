require 'rails_helper'

RSpec.describe Lesson, type: :model do
  it 'finished?' do
    date = Date.today
    lesson = Lesson.new(date_at: date.yesterday)
    expect(lesson.finished?).to eq true
  end
end
