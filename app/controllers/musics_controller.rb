class MusicsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def index
    @musics = Music.all
  end

  def new
    @music = Music.new
  end

  def create
    @music = current_user.musics.build(music_params)
    if @music.save
      redirect_to musics_path, notice: 'Music uploaded successfully.'
    else
      render :new
    end
  end

  private

  def music_params
    params.require(:music).permit(:title, :artist, :file)
  end
end
