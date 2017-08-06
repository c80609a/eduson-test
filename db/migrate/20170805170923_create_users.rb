class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :title
      t.string :role
      t.string :group

      t.timestamps
    end
  end
end
