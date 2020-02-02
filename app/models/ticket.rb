class Ticket < ApplicationRecord
  enum number_owned: {one: 1, three: 3, five: 5}

  attr_accessor :stripe_token

  belongs_to :user
  has_many :lessons

  validates :number_owned, inclusion: {in: Ticket.number_owneds.keys}

  def self.number_owned_to_amount(no)
    if no == 'one'
      2000
    elsif no == 'three'
      5000
    elsif no == 'five'
      7500
    else
      0
    end
  end

  def payment
    amount = Ticket.number_owned_to_amount(self.number_owned)
    begin
      charge = Stripe::Charge.create(source: self.stripe_token, amount: amount,
        description: "ユーザ: #{self.user_id} #{self.ticket_name}支払い", currency: 'jpy')
      return self.save
    rescue Stripe::CardError => e
      errors.add(:base, "決済でエラーが発生しました。#{e.message}")
    rescue Stripe::InvalidRequestError => e
      errors.add(:base, "決済(stripe)でエラーが発生しました（InvalidRequestError）#{e.message}")
    rescue Stripe::AuthenticationError => e
      errors.add(:base, "決済(stripe)でエラーが発生しました（AuthenticationError）#{e.message}")
    rescue Stripe::APIConnectionError => e
      errors.add(:base, "決済(stripe)でエラーが発生しました（APIConnectionError）#{e.message}")
    rescue Stripe::StripeError => e
      errors.add(:base, "決済(stripe)でエラーが発生しました（StripeError）#{e.message}")
    end
    false
  end

  def ticket_name
    Ticket.human_attribute_name('number_owned.' + self.number_owned)
  end

  def number_used
    self.lessons.length
  end
end
