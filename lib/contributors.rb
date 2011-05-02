# encoding: utf-8

require "grit"

class Contributors
  attr_reader :path
  def initialize(path = Dir.pwd)
    @path = path
  end

  def repo
    @repo ||= Grit::Repo.new(@path)
  end

  def authors_and_commits
    hash = Hash.new { |hash, key| hash[key] = Array.new }
    repo.commits("master", false).reduce(hash) do |buffer, commit|
      key = buffer.keys.find { |author| author.email == commit.author.email }
      key ||= commit.author

      buffer[key] << commit
      buffer
    end
  end

  # ["additions", "deletions", "total"]
  def list(criterium = :total)
    unless [:additions, :deletions, :total].include?(criterium)
      raise ArgumentError.new("Criterium can be one of: :additions, :deletions or :total.")
    end

    authors_and_commits.reduce(Hash.new) do |buffer, pair|
      author, commits = pair
      buffer[author] = {
        commits: commits.length,
        LOC: commits.reduce(0) do |lines, commit|
          lines + commit.stats.to_hash[criterium.to_s]
        end
      }

      buffer
    end
  end

  def results(sort_by = :LOC, criterium = :total)
    unless [:commits, :LOC].include?(sort_by)
      raise "Sort_by argument can be only :commits or :LOC!"
    end

    # Note: Hash#sort_by(&block) returns an Array, even on 1.9,
    # which isn't really necessary, as hashes on 1.9 are sorted.
    sorted_array = self.list(criterium).sort_by { |_, data| data[sort_by] }
    sorted_array.reverse.reduce(Hash.new) do |buffer, pair|
      author, stats = pair
      buffer.merge(author => stats)
    end
  end
end
