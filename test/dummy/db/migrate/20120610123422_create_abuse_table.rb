class CreateAbuseTable < ActiveRecord::Migration
  def change
    create_table :abuses do |t|
      t.string :ip_address
      t.integer :failed_attempts
      t.boolean :banned
      t.timestamps
    end
    
    add_index :abuses, :ip_address
    add_index :abuses, :banned
  end
end
