class RemoveIndexFromAuthority < ActiveRecord::Migration[5.1]
  def change
    remove_index :qa_local_authority_entries, name: "index_qa_local_authority_entries_on_uri"
  end
end
