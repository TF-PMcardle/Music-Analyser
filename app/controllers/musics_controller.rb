require 'aubio'
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

  def home
  end  

  def create
    @music = current_user.musics.build(music_params)
    if @music.save
      analysis_results = analyze_music(@music)
      @bpm = analysis_results[:bpm]
      @key = analysis_results[:key]
      render :show, notice: 'Music uploaded successfully.'
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

  require 'open3'

  def analyze_music(music)
    if music.file.attached?
      temp_file = Tempfile.new(['audio', '.wav'])
      temp_file.binmode
      temp_file.write(music.file.download)
      temp_file.rewind
  
      sample_rate = 44100  # Ensure this matches your audio file's sample rate
  
      begin
        Rails.logger.debug "Opening Aubio with sample_rate: #{sample_rate}"
  
        # Open the audio file using Aubio
        audio_file = Aubio.open(temp_file.path, sample_rate: sample_rate)
  
        # Extract the desired information
        bpm = audio_file.beats.to_a  # Convert the enumerator to an array for beats
        pitches = audio_file.pitches.to_a  # Convert the enumerator to an array for pitches
  
        Rails.logger.debug "Beats: #{bpm}, Pitches: #{pitches}"
  
        temp_file.close
        temp_file.unlink
  
        { bpm: bpm, key: pitches }
      rescue ArgumentError => e
        Rails.logger.error("Aubio analysis failed: #{e.message}")
        temp_file.close
        temp_file.unlink
        { bpm: nil, key: nil }
      rescue TypeError => e
        Rails.logger.error("TypeError in Aubio analysis: #{e.message}")
        temp_file.close
        temp_file.unlink
        { bpm: nil, key: nil }
      ensure
        audio_file.close if audio_file
      end
    else
      { bpm: nil, key: nil }
    end
  end
  
  
  
  def convert_to_wav(input_path, output_path)
    # Use ffmpeg to convert mp3 to wav
    ffmpeg_command = "ffmpeg -i #{input_path} #{output_path}"
    Open3.capture3(ffmpeg_command) # This runs the command
  end
  
  private

  def music_params
    params.require(:music).permit(:file, :genre, :release_date, :notes)  
  end
end
