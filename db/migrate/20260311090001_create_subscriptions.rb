class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :shop, null: false, foreign_key: true
      t.string :plan, null: false
      t.string :status, null: false
      t.string :shopify_charge_id, null: false

      t.timestamps
    end

    add_index :subscriptions, :shopify_charge_id, unique: true
  end
end
