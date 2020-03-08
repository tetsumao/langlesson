class Ticket < ApplicationRecord
  enum number_owned: {one: 1, three: 3, five: 5, seven: 7, ten: 10}

  attr_accessor :stripe_token

  belongs_to :user
  has_many :lessons

  validates :number_owned, inclusion: {in: Ticket.number_owneds.keys}

  def self.number_owned_to_amount(no)
    sym = no.to_sym
    if sym == :one
      2000
    elsif sym == :three
      5000
    elsif sym == :five
      7500
    else
      0
    end
  end

  def payment
    amount = Ticket.number_owned_to_amount(self.number_owned)
    begin
      if amount > 0
        charge = Stripe::Charge.create(customer: self.user.stripe_cusid, amount: amount,
          description: "ユーザ: #{self.user_id} #{self.ticket_name}支払い", currency: 'jpy')
        self.stripe_invid = charge.id
        return self.save
      else
        errors.add(:base, '選択されているチケットは不正です。')
      end
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
