#
# Contributors:
#   Tom Fakes    - Initial simple implementation, plugin implementation
#   Dan Kubb     - Handle multiple encodings, correct response headers
#   Sebastian    - Handle component requests
#
#   later modified by Aaron Namba/Bigger Bird Creative, Inc.:
#    - don't compress before caching (was writing compressed output to disk
#      and unknowingly serving it w/o Content-Encoding)
#    - TODO: don't compress unless it is a known compressible type
#      (e.g. text/html, text/xml, text/javascript)
#

begin
  require 'stringio'
  require 'zlib'
  COMPRESSION_DISABLED = false
rescue
  COMPRESSION_DISABLED = true
  RAILS_DEFAULT_LOGGER.info "Output Compression not available: " + $!
end

module CompressionSystem

  def compress_output
    return if COMPRESSION_DISABLED
    return if request.is_component_request?
    return if response.headers['Content-Encoding'] || 
              !request.env['HTTP_ACCEPT_ENCODING']
    
    begin
      request.env['HTTP_ACCEPT_ENCODING'].split(/\s*,\s*/).each do |encoding|
        # TODO: use "q" values to determine user agent encoding preferences
        case encoding
          when /\Agzip\b/
            StringIO.open('', 'w') do |strio|
              begin
                gz = Zlib::GzipWriter.new(strio)
                gz.write(response.body)
                response.body = strio.string
              ensure
                gz.close if gz
                gz = nil
              end
            end
          when /\Adeflate\b/
            response.body = Zlib::Deflate.deflate(response.body, Zlib::BEST_COMPRESSION)
          when /\Aidentity\b/
            # do nothing for identity
          else
            next # the encoding is not supported, try the next one
        end
        logger.info "Response body was encoded with #{encoding}" 
        response.headers['Content-Encoding'] = encoding
        break    # the encoding is supported, stop
      end
    end
    response.headers['Content-Length'] = response.body.length
    if response.headers['Vary'] != '*'
      response.headers['Vary'] = 
      response.headers['Vary'].to_s.split(',').push('Accept-Encoding').uniq.join(',')
    end
  end

end

# Handle component requests by not compressing the output from a component
module ActionController
  # These methods are available in both the production and test Request objects.
  class AbstractRequest
    attr_accessor :is_component_request
    
    # Returns true when the request corresponds to a render_component call
    def is_component_request?
      @is_component_request
    end
  end
  
  class Base
    include CompressionSystem
  end
end

# Mark the request as being a Component request
module ActionController
  module Components
    module InstanceMethods
      private
        alias :original_request_for_component :request_for_component
        def request_for_component(controller_name, options)
          request_for_component = original_request_for_component(controller_name, options)
          request_for_component.is_component_request = true
          request_for_component
        end
    end
  end
end

module ActionController
  module Caching
    module Pages
      module ClassMethods  	
        def caches_page(*actions)
          return unless perform_caching
          actions.each do |action|
            class_eval "after_filter { |c| c.cache_page if c.action_name == '#{action}' }"
            class_eval "skip_after_filter :compress_output, :only => [ :#{action} ]"
          end
        end
      end
    end
  end
end