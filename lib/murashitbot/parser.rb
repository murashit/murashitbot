# -*- encoding: utf-8 -*-
require 'MeCab'
require 'kconv'

module Murashitbot
  class Parser
    def self.start(name)
      self.load("./#{name}/source.txt")
    end

    def self.load(path)
      self.parse File.read(path).toutf8
    end

    def self.parse(string)
      tagger = MeCab::Tagger.new("-Ochasen")
      list = tagger.parse(string.delete("\n").gsub(/，/,"、").
                          gsub(/．/,"。")).toutf8.split(/\n/)
      list.pop
      unique_list = list.uniq

      keys = [:appearance, :yomi, :infinitive, :class,
              :conjugation1, :conjugation2]
      corpus = unique_list.map {|line| Hash[keys.zip(line.split(/\t/))]}

      sequence = list.map {|line| unique_list.index(line)}

      locations = Array.new(corpus.length) {[]}
      sequence.each_with_index {|id, l| locations[id] << l}

      Murashitbot::Db.new(corpus, sequence, locations)
    end
  end
end
