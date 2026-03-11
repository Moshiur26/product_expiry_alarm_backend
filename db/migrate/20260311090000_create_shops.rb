class CreateShops < ActiveRecord::Migration[8.1]
  def change
    create_table :shops do |t|
      t.string :shopify_domain, null: false
      t.string :access_token, null: false
      t.datetime :installed_at, null: false

      t.timestamps
    end

    add_index :shops, :shopify_domain, unique: true
  end
end
