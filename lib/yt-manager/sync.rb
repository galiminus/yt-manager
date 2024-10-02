require 'shellwords'
require 'date'

module YtManager
  class Sync

    def initialize(channels:, output_dir:, since_days_ago:)
      @channels = channels
      @output_dir = output_dir
      @since_days_ago = since_days_ago
    end

    def run
      FileUtils.mkdir_p(@output_dir.to_s)

      @channels.each do |channel|
        next unless channel.match?(/https:\/\/www\.youtube\.com/)

        output = `yt-dlp --extractor-args "youtubetab:approximate_date" --flat-playlist --print "id,upload_date" #{Shellwords.escape channel}`

        videos = []
        output.split.each_with_index do |line, index|
          if index.even?
            videos << { id: line }
          else
            videos[-1][:upload_date] = Date.parse(line)
          end
        end

        videos.select do |video|
          if (Date.today - video[:upload_date]).to_i > @since_days_ago.to_i
            next
          end

          if Dir["#{@output_dir}/*"].any? { |file| file.match(video[:id]) }
            next
          end

          # Download file
          system('yt-dlp', "https://www.youtube.com/watch?v=#{video[:id]}", "-o", "#{@output_dir}/%(title)s [%(id)s].%(ext)s")
        end
      end
    end
  end
end
