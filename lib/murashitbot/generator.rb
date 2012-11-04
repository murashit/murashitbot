require 'thor/group'
require 'oauth'
require 'json'

module Murashitbot
  class Generator < Thor::Group
    include Thor::Actions
    argument :init
    argument :name, :type => :string, :required => true

    def self.destination_root
      File.dirname(__FILE__)
    end

    def auth
      say "Create an app and get Consumer Key/Secret.", :green
      say "https://dev.twitter.com/", :green

      begin
        print "\tConsumer Key: "
        con_key = STDIN.gets.chomp

        print "\tConsumer Secret "
        con_secret = STDIN.gets.chomp

        oauth = OAuth::Consumer.new(
          con_key,
          con_secret,
          site: "http://twitter.com")

          request_token = oauth.get_request_token
      rescue
        say "Authorization failed, try again.", :red
        retry
      end

        say "Authorization succeeded!\n", :green
        say "Access here and get the PIN code.", :green
        say request_token.authorize_url, :green

        begin
          say "\tEnter your PIN code: "
          pin = STDIN.gets.to_i

          access_token = request_token.get_access_token(oauth_verifier: pin)
        rescue
          say "Authorization failed, try again.", :red
          retry
        end
        say "Authorization succeeded!\n", :green

        @consumer = {key: con_key, secret: con_secret}
        @access = {token: access_token.token, secret: access_token.secret}
    end

    def generate
      say "Initializing...", :green
      config = YAML.dump({username: name, consumer: @consumer, access: @access, laststatus: 0})
      create_file("#{name}/config.yml", config)
      create_file("#{name}/source.txt", "")
      say "Done!!", :green
    end
  end
end
