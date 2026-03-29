class AddSalaryCurrencyToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :salary_currency, :string, default: "INR"
  end
end
