require "multi_grep/version"

module MultiGrep
  class Grep
    attr_accessor :regex, :matches, :silent, :invert_match

    def initialize
      self.regex = Regexp.new ''
      self.matches = Hash.new { Set.new }
      self.silent = false
    end

    def silence
      self.silent = !silent
    end


    def regex=(r)
      @regex = Regexp.new r
    end

    def match_file(filename)
      open(filename).each_line do |line|
        if match_data = regex.match(line.strip)
          all_match = true
          match_data.names.each do |name|
            if name[0..1] == "__"
              all_match = all_match && !matches[name[2..-1]].include?(match_data[name])
            elsif name[0] == "_"
              all_match = all_match && matches[name[1..-1]].include?(match_data[name])
            else
              matches[name] = matches[name] << match_data[name]
            end
          end
          output "#{filename}: #{line}" if all_match && !silent
        end
      end
      output ""
      self.silent = false
    end

    def debug
      puts "Named captures:"
      ap matches
    end

    def output(*arg)
      puts *arg unless self.silent
    end

  end
end
