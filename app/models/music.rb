class Music < ApplicationRecord
  has_one_attached :file
  belongs_to :user

  before_save :set_title_and_artist_from_filename

  private

  def set_title_and_artist_from_filename
    return unless file.attached? && (title.blank? || artist.blank?)

    # Get the file name without the extension
    file_name = File.basename(file.filename.to_s, ".*")

    # Split the file name by " - " (you can adjust this logic based on your naming convention)
    parts = file_name.split(" - ")
    self.artist = parts[0] if artist.blank?
    self.title = parts[1] if title.blank? && parts.length > 1
  end

  class AddBpmAndKeyToMusics < ActiveRecord::Migration[7.1]
    def change
      add_column :musics, :bpm, :float
      add_column :musics, :key, :string
    end
  end
  
end
