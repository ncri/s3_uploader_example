class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.string :file_name
      t.string :file_type
      t.string :file_size
      t.string :s3_key

      t.timestamps
    end
  end
end
