class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :uid
      t.string :first_name
      t.string :last_name
      t.string :sex
      t.text :image_path
      t.timestamps
    end
  end
end
