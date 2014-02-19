class CreateViews < ActiveRecord::Migration
  def change
    create_table :views do |t|
      t.string :person_uid
      t.integer :user_id

      t.timestamps
    end
  end
end
