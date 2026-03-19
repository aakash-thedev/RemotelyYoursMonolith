# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_one :profile, dependent: :destroy
  has_one :subscription, dependent: :destroy
  has_many :job_matches, dependent: :destroy

  # Allow `.name` as alias for `.full_name` so services can use either
  alias_attribute :name, :full_name

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validates :full_name, presence: true
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }

  before_save :downcase_email

  def active_subscription?
    subscription&.active?
  end

  def pro?
    subscription&.pro? && subscription&.active?
  end

  private

  def downcase_email
    self.email = email&.downcase&.strip
  end
end
