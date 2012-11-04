require 'thor'

module Murashitbot
  class Command < Thor
    desc 'init USERNAME', 'Authorize and generate config file.'
    def init(name)
      Murashitbot::Generator.start
    end

    desc 'parse USERNAME', 'Parse source.txt and cache results.'
    def parse(name)
      db = Murashitbot::Parser.start(name)
      db.dump(name)
    end

    desc 'tweet USERNAME', '...'
    def tweet(name)
      c = Murashitbot::Client.new(name)
      c.post
    end

    desc 'reply USERNAME', '@...'
    def reply(name)
      c = Murashitbot::Client.new(name)
      c.reply
    end

    desc :usage, 'Show usage.'
    def usage
      puts <<-EOM
Usage:
  # 1. Initialize
  $ mkdir bots; cd bots
  $ murashitbot init USERNAME

  # 2. Edit USERNAME/source.txt

  # 3. Parse
  murashitbot parse USERNAME

  # 4. Tweet!!
  $ murashitbot post USERNAME
  $ murashitbot reply USERNAME
      EOM
    end
  end
end

