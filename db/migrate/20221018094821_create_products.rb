class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :product_name
      t.integer :amount_aviable
      t.integer :cost
      t.bigint :seller_id, null: false, foreign_key: true

      t.timestamps
    end
  end
end
