module Juggernaut # :nodoc:
  module JuggernautHelper

    def listen_to_juggernaut_channels(channels = nil, unique_id = "null", options = {})
      port = Juggernaut::CONFIG["PUSH_PORT"]
      num_tries = Juggernaut::CONFIG["NUM_TRIES"]
      num_secs = Juggernaut::CONFIG["NUM_SECS"]
      base64 = Juggernaut::CONFIG["BASE64"] ? true : false
      channels = Array(channels || Juggernaut::CONFIG["DEFAULT_CHANNELS"])
      channels = channels.map { |c| CGI.escape(c.to_s) }.to_json
      content = content_tag :div, '', :id=>'flashcontent', :style => "width:#{(options[:width] || "0")}; height:#{(options[:height] || "0")};"
      content += javascript_tag %{Juggernaut.debug = true;} if Juggernaut::CONFIG["LOG_ALERT"] == 1
      content += javascript_tag %{Juggernaut.listenToChannels({ 
                                host: '#{request.host}', 
                                num_tries: #{num_tries}, 
                                ses_id: '#{session.session_id}', 
                                callback_url: '#{request.ssl? ? 'https' : 'http'}://#{request.host}:#{request.port}#{options[:callback_url] || ''}',
                                num_secs: #{num_secs},
                                unique_id: '#{unique_id}',
                                swf_address: '#{options[:swf_address] || "/juggernaut.swf"}', 
                                flash_version: '#{options[:flash_version] || "8"}',
                                width: '#{options[:width] || "1"}',
                                height: '#{options[:height] || "1"}',
                                base64: #{base64},
                                port: #{port},
                                channels: #{channels}});}
      content
    end
    
  end
end
