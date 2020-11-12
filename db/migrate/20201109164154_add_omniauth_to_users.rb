class AddOmniauthToUsers < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :provider, :string unless column_exists?(:users, :provider)
    add_column :users, :uid, :string unless column_exists?(:users, :uid)
    add_column :users, :guest, :boolean, default: false unless column_exists?(:users, :guest)
    add_index :users, :uid unless index_exists?(:users, :uid)
    add_column :users, :display_name, :string unless column_exists?(:users, :display_name)
  end

  def down
    remove_column :users, :provider if column_exists?(:users, :provider)
    remove_column :users, :uid if column_exists?(:users, :uid)
    remove_column :users, :guest if column_exists?(:users, :guest)
    remove_index :users, :uid if index_exists?(:users, :uid)
    remove_column :users, :display_name if column_exists?(:users, :display_name)
  end
end
