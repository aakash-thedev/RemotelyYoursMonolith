# frozen_string_literal: true

module Api
  module V1
    class SubscriptionsController < ApplicationController
      # GET /api/v1/subscription
      def show
        subscription = current_user.subscription

        if subscription
          render json: subscription_response(subscription), status: :ok
        else
          render json: {
            plan: "free",
            status: "inactive",
            message: "No active subscription"
          }, status: :ok
        end
      end

      # POST /api/v1/subscription/create_order
      def create_order
        plan = params[:plan]

        unless Subscription::PLANS.key?(plan&.to_sym)
          render json: { error: "Invalid plan. Choose from: #{Subscription::PLANS.keys.join(', ')}" },
                 status: :unprocessable_entity
          return
        end

        plan_config = Subscription::PLANS[plan.to_sym]
        amount = plan_config[:amount] # amount in paise (INR)

        if razorpay_configured?
          # Real Razorpay order
          razorpay_order = Razorpay::Order.create(
            amount: amount,
            currency: "INR",
            receipt: "ry_#{current_user.id}_#{Time.current.to_i}",
            notes: { user_id: current_user.id, plan: plan }
          )

          render json: {
            message: "Order created",
            order: {
              order_id: razorpay_order.id,
              plan: plan,
              amount: amount,
              currency: "INR",
              status: razorpay_order.status,
              key_id: ENV["RAZORPAY_KEY_ID"]
            }
          }, status: :created
        else
          # Dev fallback — generates a fake order for local testing
          render json: {
            message: "Order created (dev mode)",
            order: {
              order_id: "order_dev_#{SecureRandom.hex(12)}",
              plan: plan,
              amount: amount,
              currency: "INR",
              status: "created",
              key_id: "rzp_test_dev"
            }
          }, status: :created
        end
      rescue Razorpay::Error => e
        render json: { error: "Payment gateway error: #{e.message}" }, status: :service_unavailable
      end

      # POST /api/v1/subscription/verify_payment
      def verify_payment
        order_id = params[:order_id]
        payment_id = params[:payment_id]
        signature = params[:signature]

        unless order_id.present? && payment_id.present?
          render json: { error: "Missing payment details" }, status: :bad_request
          return
        end

        if razorpay_configured?
          # Verify Razorpay signature
          unless signature.present?
            render json: { error: "Missing payment signature" }, status: :bad_request
            return
          end

          payment_response = {
            razorpay_order_id: order_id,
            razorpay_payment_id: payment_id,
            razorpay_signature: signature
          }

          begin
            Razorpay::Utility.verify_payment_signature(payment_response)
          rescue Razorpay::Error
            render json: { error: "Payment verification failed — invalid signature" }, status: :unprocessable_entity
            return
          end
        else
          Rails.logger.info("[Subscriptions] Dev mode — skipping signature verification for #{order_id}")
        end

        # Activate subscription
        subscription = current_user.subscription || current_user.build_subscription
        subscription.assign_attributes(
          plan: params[:plan] || "pro",
          status: "active",
          razorpay_payment_id: payment_id,
          order_id: order_id,
          started_at: Time.current,
          expires_at: 1.month.from_now
        )

        if subscription.save
          render json: {
            message: "Payment verified and subscription activated",
            subscription: subscription_response(subscription)
          }, status: :ok
        else
          render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/subscription/cancel
      def cancel
        subscription = current_user.subscription

        unless subscription&.active?
          render json: { error: "No active subscription to cancel" }, status: :not_found
          return
        end

        subscription.update!(status: "cancelled", cancelled_at: Time.current)

        render json: {
          message: "Subscription cancelled. Access continues until #{subscription.expires_at&.strftime('%B %d, %Y')}.",
          subscription: subscription_response(subscription)
        }, status: :ok
      end

      private

      def razorpay_configured?
        ENV["RAZORPAY_KEY_ID"].present? && ENV["RAZORPAY_KEY_SECRET"].present?
      end

      def subscription_response(subscription)
        {
          id: subscription.id,
          plan: subscription.plan,
          status: subscription.status,
          started_at: subscription.started_at,
          expires_at: subscription.expires_at,
          cancelled_at: subscription.cancelled_at,
          days_remaining: subscription.days_remaining
        }
      end
    end
  end
end
