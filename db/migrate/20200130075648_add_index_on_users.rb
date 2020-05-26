class AddIndexOnUsers < ActiveRecord::Migration[5.1]
  def change
    add_index :users, [:email, :deleted_at], unique: true
  end
end
