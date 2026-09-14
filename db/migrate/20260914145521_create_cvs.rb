class CreateCvs < ActiveRecord::Migration[8.1]
  def change
    create_table :cvs do |t|
      t.timestamps
    end
  end
end
