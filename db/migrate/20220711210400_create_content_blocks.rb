class CreateContentBlocks < ActiveRecord::Migration[5.1]
  def change
    create_table :content_blocks do |t|
      t.string :reference
      t.string :value

      t.timestamps
    end
  end
end
