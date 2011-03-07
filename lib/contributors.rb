# encoding: utf-8

# TODO: Use Grit or something rather than this black magic.
class Contributors
  IGNORED_PATTERNS = [/^vendor\//, /^gems\//, /.+\.gem$/]

  attr_reader :path, :ignored_patterns
  def initialize(path = Dir.pwd, ignored_patterns = IGNORED_PATTERNS)
    @path, @ignored_patterns = path, ignored_patterns
  end

  def list
    repo do
      authors = %x{git log | grep ^Author:}.split("\n")
      results = authors.reduce(Hash.new) do |results, line|
        line.match(/^Author: (.+) <(.+)>$/)
        name, email = $1, $2
        results[email] ||= Hash.new
        results[email][:name] = name
        results[email][:commits] ||= 0
        results[email][:commits] += 1
        results[email][:LOC] = loc[email]
        results
      end
    end
  end

  def results(sort_by = :LOC)
    unless [:commits, :LOC].include?(sort_by)
      raise "Sort_by argument can be only :commits or :LOC!"
    end

    self.list.sort_by { |_, data| data[sort_by] }.reverse
  end

  private
  def repo(&block)
    Dir.chdir(@path, &block)
  end

  def files
    files = %x{git ls-files}.split("\n")
    files.select do |path|
      self.ignored_patterns.any? do |pattern|
        not path.match(pattern)
      end
    end
  end

  # TODO: At the moment this are any lines, not lines of code.
  # {email_1 => LOC for email_1, email_2 => LOC for email_2}
  def loc
    @loc ||= begin
      files.reduce(Hash.new) do |buffer, path|
        emails = %x{git blame '#{path}' --show-email | awk '{ print $2 }' | ruby -pe '$_.sub!(/^.*<(.+)>.*$/, "\\\\1")'}
        emails.split("\n").each do |email|
          buffer[email] ||= 0
          buffer[email] += 1
        end

        buffer
      end
    end
  end
end
