class AddDetailsToMusics < ActiveRecord::Migration[7.1]
  def change
    add_column :musics, :genre, :string
    add_column :musics, :release_date, :date
    add_column :musics, :notes, :text
  end
end
