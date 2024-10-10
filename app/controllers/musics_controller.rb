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
        bpm = bpm.round(0) - 3.0
        
        # Get Pitches
        pitches = get_file_pitches(temp_file.path)

        key = detect_key(pitches)
  
        # Save results to music record
        music.update(bpm: bpm, key: key) if bpm
  
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

  def detect_key(pitches)
    note_names = %w[C C# D D# E F F# G G# A A# B]
    note_counts = Hash.new(0)
  
    # Convert frequencies to musical note indices
    pitches.each do |frequency|
      next if frequency == 0.0  # Ignore zero frequencies (silence)
  
      note_index = (69 + 12 * Math.log2(frequency / 440.0)).round % 12
      note_counts[note_index] += 1
    end
  
    # Find the most common note index
    most_common_note = note_counts.max_by { |_, count| count }&.first
  
    return "Unknown" unless most_common_note
  
    # Determine major or minor (for simplicity, using a basic assumption)
    key_name = note_names[most_common_note]
    is_minor = determine_if_minor(pitches)
  
    key_name += is_minor ? "m" : "M"  # Append 'm' for minor, 'M' for major
    key_name
  end
  
  # Method to heuristically determine if the key is minor
  def determine_if_minor(pitches)
    # For simplicity, assume keys are minor if lower pitch frequencies dominate
    # More advanced detection may use other harmonic information
    pitches.sum / pitches.size < 440  # Return true if average pitch is lower than A4
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

  def recommendations
    @music = Music.find(params[:id])

    if @music.bpm.present? && @music.key.present?
      # Call method to get Spotify recommendations
      @recommendations = get_spotify_recommendations(@music.bpm, @music.key)
    else
      @recommendations = []
      flash[:alert] = "Cannot get recommendations without BPM and key."
    end
  end

  private

  def get_spotify_recommendations(bpm, key)
    # Map your key format (e.g., C, C#m) to Spotify's key format (C = 0, C# = 1, ..., B = 11)
    note_to_spotify_key = {
      "C" => 0, "C#" => 1, "D" => 2, "D#" => 3, "E" => 4, "F" => 5,
      "F#" => 6, "G" => 7, "G#" => 8, "A" => 9, "A#" => 10, "B" => 11
    }
    
    # Extract root note and minor/major
    root_note = @music.key.gsub(/[mM]/, "")  # Remove minor/major marker
    is_minor = @music.key.end_with?("m")
    mode = is_minor ? 0 : 1  # Minor = 0, Major = 1

    spotify_key = note_to_spotify_key[root_note]

    # Use Spotify's Recommendations API
    recommendations = RSpotify::Recommendations.generate(
      limit: 10,  # Number of recommendations
      seed_genres: ["pop", "rock"],  # Modify as needed
      target_tempo: bpm,
      target_key: spotify_key,
      target_mode: mode
    )

    recommendations.tracks
  end

  def music_params
    params.require(:music).permit(:title, :artist, :file, :genre, :release_date, :notes)  
  end
end
