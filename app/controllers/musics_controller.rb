class MusicsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def index
    @musics = Music.all
  end

  def show
    @music = Music.find(params[:id])
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

  def edit
    @music = Music.find(params[:id])
  end

  def update
    @music = Music.find(params[:id])
    if @music.update(music_params)
      flash[:notice] = "Music was successfully updated."
      redirect_to musics_path
    else
      render :edit
    end
  end

  def destroy
    @music = Music.find(params[:id])
    @music.destroy
    flash[:notice] = "Song deleted successfully."
    redirect_to musics_path
  end
  private

  def music_params
    params.require(:music).permit(:title, :artist, :file)
  end
end
