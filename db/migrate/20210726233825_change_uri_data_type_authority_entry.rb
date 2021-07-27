class ChangeUriDataTypeAuthorityEntry < ActiveRecord::Migration[5.1]
  def change
    change_column :qa_local_authority_entries, :uri, :text
  end
end
