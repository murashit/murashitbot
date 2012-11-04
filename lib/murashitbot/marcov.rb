# -*- encoding: utf-8 -*-

module Murashitbot
  class Marcov
    def initialize(db, head_candidates, maxlength)
      @db = db
      @ids = db.sequence[head_candidates.sample, 4]
      @maxlength = maxlength
    end

    def chain
      return fix_brackets(@db.id_to_str(iterate([], @ids)).gsub(/[^。！？…]*?$/, ""))
    end

    private
    def iterate(stack, ids)
      if stack.length > @maxlength
        return stack

      else
        locations = @db.id_to_loc([ids[2]])
        ids_list = locations.map {|l| @db.sequence[l, 4]}
        loc_with_ids = Hash[locations.zip(ids_list)]

        candidates = loc_with_ids.reduce([]) do |hc, (key, val)|
          hc << key if val[0..1] == ids[2..3]; hc
        end

        iterate(stack + ids[0..1], @db.sequence[candidates.sample, 4])
      end
    end

    def fix_brackets(str)
      brackets = [['【','】'],['<','>'],['＜','＞'],['(',')'],['（','）'],
                  ['「','」'],['『','』'],['[',']'],['"','"']] # 括弧の対応
      delimiter = brackets.join('|').split('|').map{|b|
        if b =~ /\(|\)|\[|\]|\"|\'/ # 正規表現のリテラルに含まれる物をエスケープ
          "\\#{b}"
        else
          b
        end
      }.join('|')
      words = str.split(/(#{delimiter})/)
      pairs = Array.new
      for i in 0...words.size do
        brackets.each{|b|
          if words[i] == b[0] # 左括弧
            for j in i...words.size do
              if words[j] == b[1] && !pairs.index(i) && !pairs.index(j)
                # 対になる括弧が右にあるか
                next if pairs.size>0 && pairs.max > i # 括弧同士の重複
                pairs << i # 対になる括弧の位置を保存しておく
                pairs << j
              end
            end
          end
        }
      end
      for i in 0...words.size do
        if words[i] =~ /#{delimiter}/ && !pairs.index(i)
          # 対応してない括弧を全て削除
          words[i] = ""
        end
      end
      words.join
    end
  end
end
