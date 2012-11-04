#-*- encoding: utf-8 -*-

module Murashitbot
  class Db
    attr_reader :corpus, :sequence, :locations

    def initialize(corpus, sequence, locations)
      @corpus = corpus
      @sequence = sequence
      @locations = locations
    end

    def self.load(name)
      corpus = open("#{name}/corpus.dat", "rb") {|f| Marshal.load(f)}
      sequence = open("#{name}/sequence.dat", "rb") {|f| Marshal.load(f)}
      locations = open("#{name}/locations.dat", "rb") {|f| Marshal.load(f)}
      self.new(corpus, sequence, locations)
    end

    def dump(name)
      hc = list_normal_head_candidates
      open("#{name}/corpus.dat", "wb") {|f| Marshal.dump @corpus, f}
      open("#{name}/sequence.dat", "wb") {|f| Marshal.dump @sequence, f}
      open("#{name}/locations.dat", "wb") {|f| Marshal.dump @locations, f}
      open("#{name}/head_candidates.dat", "wb") {|f| Marshal.dump hc, f}
    end

    ## 相互変換
    def id_to_loc(ids)
      @locations.values_at(*ids).flatten
    end

    def loc_to_id(locs)
      @sequence.values_at(*locs)
    end

    def id_to_str(ids)
      ids.map {|id| @corpus[id]}.reduce("") do |string, feature|
        string << feature[:appearance]
      end
    end

    ## 頭語候補のリストアップ
    ## ふつうのポスト
    def list_normal_head_candidates
      tail_words = /.*[。？！…」].*/
      tail_locations = id_to_loc(search(:appearance, tail_words))
      tail_locations.reject!{|l| tail_locations.include?(l+1)}
      head_locations = tail_locations.map{|l| l+1}
      head_locations.unshift(0).pop
      return head_locations
    end

    ## リプライ
    def list_reply_head_candidates(reply_db)
      head_locations = intersect(reply_db) & id_to_loc(search(:class, /.*名詞.*/))
      if head_locations.length == 0
        head_locations = id_to_loc(search(:yomi, /アナタ|キミ|オマエ/))
      end
      return head_locations
    end

    private
    def intersect(db)
      list = db.corpus.map {|feature| @corpus.index(feature)}
      return list.compact
    end

    ## 特定の情報を持つ語彙を探し、locationを返す
    def search(key, val)
      list = @corpus.each_with_index.reduce([]) do |list, (feature, id)|
        list << id if val =~ feature[key]; list
      end
      return list
    end
  end
end
