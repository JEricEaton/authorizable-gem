class AddProductManagerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :product_manager, :boolean, default: 0
  end
end
