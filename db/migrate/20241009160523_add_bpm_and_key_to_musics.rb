class AddBpmAndKeyToMusics < ActiveRecord::Migration[7.1]
  def change
    add_column :musics, :bpm, :float
    add_column :musics, :key, :string
  end
end
