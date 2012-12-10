#-*- encoding: utf-8 -*-
require 'twitter'
require 'yaml'

class RedoCountExceeded < StandardError; end

module Murashitbot
  class Client
    def initialize(name)
      @config = YAML.load_file "#{name}/config.yml"
      Twitter.configure do |conf|
        conf.consumer_key = @config[:consumer][:key]
        conf.consumer_secret = @config[:consumer][:secret]
        conf.oauth_token = @config[:access][:token]
        conf.oauth_token_secret = @config[:access][:secret]
      end
      @client = Twitter::Client.new
      @name = name
      @length = 80
      @db = Murashitbot::Db.load(name)
    end

    def post
      nhc = open("#{@name}/head_candidates.dat", "rb") {|f| Marshal.load(f)}
      marcov = Murashitbot::Marcov.new(@db, nhc, @length)
      begin
        raise RedoCountExceeded if redo_count > 9
        status = marcov.chain
        status.gsub!(/[^。！？…]*?[。！？…]*?$/, "") if status.length > 140
        @client.update(status)
      rescue RedoCountExceeded
      rescue
        redo_count += 1
        redo
      end
    end

    def reply
      laststatus = @config[:laststatus].to_i
      mentions = @client.mentions
      ## laststatusよりも新しいものだけ選び、さらに古い順に並べる
      mentions.keep_if {|m| m.id > laststatus}.reverse!

      if mentions.length > 0
        mentions.each do |m|
          at_id = m.user.screen_name
          re_db = Murashitbot::Parser.parse(m.text.toutf8.delete("@#{@name} "))
          hc = @db.list_reply_head_candidates(re_db)
          marcov = Murashitbot::Marcov.new(@db,hc,@length)
          redo_count = 0
          begin
            raise RedoCountExceeded if redo_count > 9
            status = "@" + at_id + " " + marcov.chain
            status.gsub!(/[^。！？…]*?[。！？…]*?$/, "") if status.length > 140
            @client.update(status, options={:in_reply_to_status_id => m.id})
          rescue RedoCountExceeded
            break
          rescue
            redo_count += 1
            redo
          end
          @config[:laststatus] = m.id
          sleep 3
        end
        @config = YAML.dump(@config)
        f = File.open("#{@name}/config.yml", "w"); f.puts @config; f.close
      end
    end
  end
end
