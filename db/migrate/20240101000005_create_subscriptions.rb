class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string  :plan,                    default: "free",   null: false
      t.string  :status,                  default: "active", null: false
      t.string  :razorpay_subscription_id
      t.string  :razorpay_payment_id
      t.string  :order_id
      t.datetime :started_at
      t.datetime :expires_at
      t.datetime :cancelled_at

      t.timestamps
    end

    add_index :subscriptions, :plan
    add_index :subscriptions, :status
  end
end
