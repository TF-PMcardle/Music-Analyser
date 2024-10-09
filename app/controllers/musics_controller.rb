require 'open3'
require 'tempfile'

class MusicsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :index]

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
      
      # No need to set @bpm and @key since they are saved to @music
      redirect_to @music, notice: 'Music uploaded successfully.'
    else
      render :new
    end
  end  

  def analyze_music(music)
    if music.file.attached?
      temp_file = Tempfile.new(['audio', '.wav'])
      temp_file.binmode
      temp_file.write(music.file.download)
      temp_file.rewind
  
      begin
        sample_rate = 44100  # Ensure this matches your audio file's sample rate
        Rails.logger.debug "Opening Aubio with sample_rate: #{sample_rate}"
  
        # Get BPM
        bpm = get_file_bpm(temp_file.path)
        bpm = bpm.round(0) - 13.0
        
        # Get Pitches
        pitches = get_file_pitches(temp_file.path)
  
        # Save results to music record
        music.update(bpm: bpm, key: pitches.join(", ")) if bpm
  
        Rails.logger.debug "Beats: #{bpm}, Pitches: #{pitches}"
  
        { bpm: bpm, key: pitches }
      rescue ArgumentError => e
        Rails.logger.error("Aubio analysis failed: #{e.message}")
        { bpm: nil, key: nil }
      rescue TypeError => e
        Rails.logger.error("TypeError in Aubio analysis: #{e.message}")
        { bpm: nil, key: nil }
      ensure
        temp_file.close
        temp_file.unlink
      end
    else
      { bpm: nil, key: nil }
    end
  end
  

  def get_file_bpm(file_path)
    stdout, stderr, status = Open3.capture3("aubio tempo -i #{file_path}")
    if status.success?
      bpm = stdout.strip.to_f  # Assuming the output is just the BPM
      bpm
    else
      Rails.logger.error("Error detecting BPM: #{stderr}")
      nil
    end
  end

  def get_file_pitches(file_path)
    stdout, stderr, status = Open3.capture3("aubio pitch -i #{file_path}")
    if status.success?
      # Filter out non-pitched (zero) values and convert to floats
      pitches = stdout.strip.split.map(&:to_f).reject { |p| p.zero? }
      pitches
    else
      Rails.logger.error("Error detecting pitches: #{stderr}")
      nil
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
    params.require(:music).permit(:title, :artist, :file, :genre, :release_date, :notes)  
  end
end
