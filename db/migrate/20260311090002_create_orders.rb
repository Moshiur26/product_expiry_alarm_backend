class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :shop, null: false, foreign_key: true
      t.string :shopify_order_id, null: false
      t.decimal :total_price, null: false, precision: 10, scale: 2

      t.timestamps
    end

    add_index :orders, :shopify_order_id
  end
end
