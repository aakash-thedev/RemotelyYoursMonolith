# frozen_string_literal: true

if ENV["RAZORPAY_KEY_ID"].present? && ENV["RAZORPAY_KEY_SECRET"].present?
  Razorpay.setup(ENV["RAZORPAY_KEY_ID"], ENV["RAZORPAY_KEY_SECRET"])
  Rails.logger.info("[Razorpay] Configured with key #{ENV['RAZORPAY_KEY_ID'][0..10]}...")
else
  Rails.logger.warn("[Razorpay] Not configured — running in dev/stub mode. Set RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET for production.")
end
