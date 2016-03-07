class CreateTasks < ActiveRecord::Migration
  def change
  	create_table :tasks do |t|
      t.text    :description
      t.string  :title
      t.string  :priority
      t.boolean :finished, default: false
      t.timestamps
  end
  end
end
