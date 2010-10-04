class ApplicationController < ActionController::Base
  before_filter :create_settings_object, :set_default_session_values, :check_ssl_requirement, :expire_session_data, :authenticate_user
  filter_parameter_logging :password, :cc_number, :cc_cvv2, :card_number, :card_cvv
  after_filter :compress_output
  
  # Call require_ssl to indicate that you want to require SSL for your controller/action.
  #
  # Note: You will want to use prepend_before_filter with this one, as it is critical 
  # that it happens before anything else.
  def require_ssl
    @require_ssl = true
  end
  
  def create_settings_object # :nodoc:
    # require 'settings_hash'
    # @settings = SettingsHash.new
  end
  
  def set_default_session_values
    session[:time_zone] ||= 'Hawaii'
    session[:time_zone_abbr] ||= 'HST'
    
    # set default expiration times
    session[:authenticated_expiration] = defined?(MemberSessionTimeout) ? MemberSessionTimeout : 60.minutes if RAILS_ENV == 'production'
    
    # set some environment variables that we can read in models
    ENV['RAILS_USER_ID'] = session[:user_id].to_s
  end
  
  def cleanup
    GC.start
  end
  
  # This helps (a lot) when you want to use a different hostname for ssl.
  # Remember to put this in your ssl.conf:
  #   RequestHeader set X_FORWARDED_PROTO 'https'
  def check_ssl_requirement # :nodoc:
    return true unless RAILS_ENV == 'production'
    return true unless defined?(SSL_REDIRECTS_ON) && SSL_REDIRECTS_ON
    
    case
      when !request.ssl? && @require_ssl
        logger.debug "redirecting to secure page"
        newparams = {}
        newparams.update(:host => (defined?(SSL_SECURE_HOST) ? SSL_SECURE_HOST : request.host) + (defined?(SSL_SECURE_PORT) ? ":#{SSL_SECURE_PORT.to_s}" : ''))
        newparams.update(:protocol => 'https://')
        redirect_to(newparams) and return false
      when request.ssl? && !@require_ssl
        logger.debug "redirecting to std"
        newparams = {}
        newparams.update(:host => (defined?(SSL_STANDARD_HOST) ? SSL_STANDARD_HOST : request.host) + (defined?(SSL_STANDARD_PORT) ? ":#{SSL_STANDARD_PORT.to_s}" : ''))
        newparams.update(:protocol => 'http://')
        redirect_to(newparams) and return false
    end
  end
  
  # Renders app/views/errors/404.rhtml with http status 404 Not Found.
  def not_found
    logger.error "404 from #{request.referer}"
    render :template => 'errors/404', :status => 404
  end
  
  def expire_session_data # :nodoc:
    # session cookie should stick around for 2 weeks
    ::ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update(:session_expires => 2.weeks.from_now)
    
    # make sure this is not the first run (session being initialized)
    if session[:last_active]
      idle_time = Time.now - session[:last_active]
      
      # expire session data as necessary
      session_data = session.instance_variable_get("@data")
      session_data.select { |k,v| k.to_s !~ /_expiration$/ && v }.each do |k,v|
        idx = k.to_s + '_expiration'
        if (exp = (session[idx] || session[idx.to_sym]).to_i) > 0
          if idle_time > exp
            logger.debug "Expiring #{k} = #{v} (expiration #{exp} > idle time #{idle_time})"
            session[k] = nil
          else
            logger.debug "Retaining #{k} = #{v} (expiration #{exp} < idle time #{idle_time})"
          end
        else
          #logger.debug "Retaining #{k} = #{v} (does not expire)"
        end
      end
    end
    
    # bump/set last active time
    session[:last_active] = Time.now
    if is_logged_in_user?
      cookies[:user_auth_status] = { :value => 'authenticated', :expires => 1.minute.from_now }
    end
    
    #
    # cache expiration is not entirely relevant, but let's try this for now
    #
    
    # clear out the cache on restart
    begin
      if !defined?(@@initialized_fragment_cache)
        expire_fragment(/.*/)
        @@initialized_fragment_cache = true
      end
    rescue Exception => e
      logger.debug "Error clearing fragment cache: #{e}"
    end
  end
  
  # Saves the current request to the session so that it can be replayed later
  # (for example, after authentication). Only params of type String, Hash and
  # Array will be saved. save_request is called in a before_filter in
  # application.rb.
  #
  # Two levels of saved params are required so that params can be unsaved in
  # the event of a 404 or other event that would make the current param set an
  # unlikely or undesirable candidate for replaying.
  def save_request
    session[:old_saved_params] = session[:saved_params] || {};
    saved_params = params.reject { |k, v| !(v.kind_of?(String) || v.kind_of?(Hash) || v.kind_of?(Array)) }
    saved_params.each { |key, val| saved_params[key] = val.reject { |k, v| !(v.kind_of?(String) || v.kind_of?(Hash) || v.kind_of?(Array)) } if val.kind_of?(Hash) }
    session[:saved_params] = saved_params
  end
  
  # Saves the current request to the session so that it can be replayed later
  # (for example, after authentication). Only params of type String, Hash and
  # Array will be saved. save_request is called in a before_filter in
  # application.rb.
  #
  # Two levels of saved params are required so that params can be unsaved in
  # the event of a 404 or other event that would make the current param set an
  # unlikely or undesirable candidate for replaying.
  def save_user_request
    session[:old_saved_user_params] = session[:saved_user_params] || {};
    saved_params = params.reject { |k, v| !(v.kind_of?(String) || v.kind_of?(Hash) || v.kind_of?(Array)) }
    saved_params.each { |key, val| saved_params[key] = val.reject { |k, v| !(v.kind_of?(String) || v.kind_of?(Hash) || v.kind_of?(Array)) } if val.kind_of?(Hash) }
    session[:saved_user_params] = saved_params
  end
  
  # Returns a Member object corresponding to the currently logged in member, or returns false
  # and redirects to the login page if not logged in.
  #
  # The message shown after redirection to the login page can be customized (UnauthenticatedUserMessage).
  def authenticate
    # see if user is disabled
    if session[:authenticated] && !Member.find(:first, :conditions => [ 'id = ? and active = 1', session[:member_id]])
      session[:authenticated] = nil
      session[:member_id] = nil
      flash[:notice] = 'Your account has been disabled by an administrator.'
      redirect_to :controller => '/members/auth', :action => 'login' and return false
    end
    
    # if user is not logged in, record the current request and redirect
    if !session[:authenticated]
      flash[:notice] = defined?(UnauthenticatedMessage) ? UnauthenticatedMessage : 'To continue, please log in.'
      save_request
      redirect_to :controller => '/management/user', :action => 'login' and return false
    end
    
    return false unless (@member = Member.find_by_id(session[:member_id]))
    @member
  end
  
  # Returns a User object corresponding to the currently logged in user, or returns false
  # and redirects to the login page if not logged in. If no Users exist, redirects to
  # :controller => 'management/user', :action => 'create_first'.
  #
  # The message shown after redirection to the login page can be customized (UnauthenticatedUserMessage).
  def authenticate_user
    # if user is not logged in, record the current request and redirect
    if (!session[:user_authenticated])
      if User.find(:all).size == 0
        flash[:notice] = 'No users exist in the system. Please create one now.'
        redirect_to :controller => '/management/user', :action => 'create_first'
      else
        flash[:notice] = defined?(UnauthenticatedUserMessage) ? UnauthenticatedUserMessage : 'This is an admin-only function. To continue, please log in.'
        save_user_request
        respond_to do |format|
          format.html { redirect_to :controller => '/management/user', :action => 'login' }
          format.js do
            session[:saved_user_params] = { :controller => '/management/user', :action => 'success_popup' }
            render :partial => '/management/user/login_popup'
          end
        end
      end
      
      return false
    end
    
    return false unless (@user = User.find_by_id(session[:user_id]))
    session[:user_is_superuser] = (@user.is_superuser == 1)
    @user
  end
  
  # Takes a symbol/string or array of symbols/strings and returns true if user has all
  # of the named permissions.
  #
  # Result is stored in the session to speed up future checks.
  def user_has_permissions?(*permission_set)
    return false if !(@user = authenticate_user)
    
    if !permission_set.is_a? Array
      permission_set = [ permission_set ]
    end
    
    if session[:user_is_superuser]
      for perm in permission_set
        perm = perm.to_s
        session[('user_can_' + perm).to_sym] = true
      end
      return true
    end
    
    for perm in permission_set
      perm = perm.to_s
      session[('user_can_' + perm).to_sym] ||= @user.send('can_' + perm).to_i == 1
      return session[('user_can_' + perm).to_sym]
    end
  end
  alias :user_has_permission? :user_has_permissions?
  helper_method :user_has_permission?
  helper_method :user_has_permissions?
  
  # Returns true if a Member is logged in.
  def is_logged_in?
    session[:authenticated]
  end
  helper_method :is_logged_in?
  
  # Returns true if a User is logged in.
  def is_logged_in_user?
    session[:user_authenticated]
  end
  helper_method :is_logged_in_user?
  
  # Returns true if the user is editing the current page.
  # (This just means that we are rendering :controller => 'management/cms', :action => 'edit_page_content'.)
  def is_editing_page?
    params[:controller] == 'management/cms' && params[:action] == 'edit_page_content'
  end
  helper_method :is_editing_page?
  
  def convert_invalid_chars_in_params
    dig_deep(params) { |s| convert_invalid_chars!(s) }
  end
  
  def dig_deep(hash, &block)
    if hash.instance_of? String
      yield(hash)
    elsif hash.kind_of? Hash
      hash.each_key { |h| dig_deep(hash[h]) { |s| block.call(s) } }
    else
      nil
    end
  end
  
  def convert_invalid_chars!(s)           
    s.gsub!(/\xe2\x80\x98/, '&lsquo;')  # ‘
    s.gsub!(/\xe2\x80\x99/, '&rsquo;')  # ’
    s.gsub!(/\xe2\x80\x9c/, '&ldquo;')  # “
    s.gsub!(/\xe2\x80\x9d/, '&rdquo;')  # ”
    s.gsub!(/\xe2\x80\x93/, '&ndash;')  # –
    s.gsub!(/\xe2\x80\x94/, '&mdash;')  # —
    s.gsub!(/\xe2\x80\xa2/, '&bull;')   # •
    s.gsub!(/\xe2\x80\xa6/, '&hellip;') # …
    s.gsub!(/\xe2\x84\xa2/, '&trade;')  # ™
    
    s.gsub!(/\xc2\xae/, '&reg;')    # ®
    s.gsub!(/\xc2\xab/, '&laquo;')  # «
    s.gsub!(/\xc2\xbb/, '&raquo;')  # »
    s.gsub!(/\xc2\xbd/, '&frac12;') # ½
    s.gsub!(/\xc2\xbc/, '&frac14;') # ¼
    
    s.gsub!(/\xc4\x80/, '&#x100;')  # Ā
    s.gsub!(/\xc4\x81/, '&#x101;')  # ā
    s.gsub!(/\xc4\x92/, '&#x112;')  # Ē
    s.gsub!(/\xc4\x93/, '&#x113;')  # ē
    s.gsub!(/\xc4\xaa/, '&#x12A;')  # Ī
    s.gsub!(/\xc4\xab/, '&#x12B;')  # ī
    s.gsub!(/\xc5\x8c/, '&#x14C;')  # Ō
    s.gsub!(/\xc5\x8d/, '&#x14D;')  # ō
    s.gsub!(/\xc5\xaa/, '&#x16A;')  # Ū
    s.gsub!(/\xc5\xab/, '&#x16B;')  # ū
    
    s.gsub!(/\xc3\x84/, '&Auml;') # Ä
    s.gsub!(/\xc3\x8b/, '&Euml;') # Ë
    s.gsub!(/\xc3\x8f/, '&Iuml;') # Ï
    s.gsub!(/\xc3\x96/, '&Ouml;') # Ö
    s.gsub!(/\xc3\x9c/, '&Uuml;') # Ü
    s.gsub!(/\xc3\xa4/, '&auml;') # ä
    s.gsub!(/\xc3\xab/, '&euml;') # ë
    s.gsub!(/\xc3\xaf/, '&iuml;') # ï
    s.gsub!(/\xc3\xb6/, '&ouml;') # ö
    s.gsub!(/\xc3\xbc/, '&uuml;') # ü
    
    s.gsub!(/\xc3\x81/, '&Aacute;') # Á
    s.gsub!(/\xc3\x89/, '&Eacute;') # É
    s.gsub!(/\xc3\x8d/, '&Iacute;') # Í
    s.gsub!(/\xc3\x93/, '&Oacute;') # Ó
    s.gsub!(/\xc3\x9a/, '&Uacute;') # Ú
    s.gsub!(/\xc3\xa1/, '&aacute;') # á
    s.gsub!(/\xc3\xa9/, '&eacute;') # é
    s.gsub!(/\xc3\xad/, '&iacute;') # í
    s.gsub!(/\xc3\xb3/, '&oacute;') # ó
    s.gsub!(/\xc3\xba/, '&uacute;') # ú
    
    s.gsub!(/\x85/, '&hellip;') # …
    s.gsub!(/\x8b/, '&lt;')     # <
    s.gsub!(/\x9b/, '&gt;')     # >
    s.gsub!(/\x91/, '&lsquo;')  # ‘
    s.gsub!(/\x92/, '&rsquo;')  # ’
    s.gsub!(/\x93/, '&ldquo;')  # “
    s.gsub!(/\x94/, '&rdquo;')  # ”
    s.gsub!(/\x97/, '&mdash;')  # —
    s.gsub!(/\x99/, '&trade;')  # ™
    s.gsub!(/\x95/, '*')
    s.gsub!(/\x96/, '-')
    s.gsub!(/\x98/, '~')
    s.gsub!(/\x88/, '^')
    s.gsub!(/\x82/, ',')
    s.gsub!(/\x84/, ',,')
    s.gsub!(/\x89/, 'o/oo')
    s.gsub!(/\x8c/, 'OE')
    s.gsub!(/\x9c/, 'oe')
  end
  
  # Convert from GMT/UTC to local time (based on time zone setting in session[:time_zone])
  def gm_to_local(time)
    TimeZone.new(session[:time_zone]).utc_to_local(time)
  end
  helper_method :gm_to_local
  
  # Convert from local time to GMT/UTC (based on time zone setting in session[:time_zone])
  def local_to_gm(time)
    TimeZone.new(session[:time_zone]).local_to_utc(time)
  end
  helper_method :local_to_gm
  
  # Convert a time object into a formatted date/time string
  def ts_to_str(ts)
    return '' if ts == nil
    gm_to_local(ts).strftime('%a %b %d, %Y') + ' at ' +
      gm_to_local(ts).strftime('%I:%M%p').downcase + ' ' + (session[:time_zone_abbr] || '')
  end
  helper_method :ts_to_str
  
  # Convert a time object into a formatted time string (no date)
  def ts_to_time_str(ts)
    return '' if ts == nil
    gm_to_local(ts).strftime('%I:%M:%S%p').downcase
  end
  helper_method :ts_to_time_str
  
  # Convert times to a standard format (e.g. 1:35pm)
  def time_to_str(t, convert = true)
    return '' if t == nil
    if convert
      gm_to_local(t).strftime("%I").to_i.to_s + gm_to_local(t).strftime(":%M%p").downcase
    else
      t.strftime("%I").to_i.to_s + t.strftime(":%M%p").downcase
    end
  end
  helper_method :time_to_str
  
  # Convert times to a standard format (e.g. 1:35pm)
  def date_to_str(t, convert = true)
    return '' if t == nil
    if convert
      gm_to_local(t).strftime("%m").to_i.to_s + '/' + gm_to_local(t).strftime("%d").to_i.to_s + gm_to_local(t).strftime("/%Y")
    else
      t.strftime("%m").to_i.to_s + '/' + t.strftime("%d").to_i.to_s + t.strftime("/%Y")
    end
  end
  helper_method :date_to_str
  
  def build_number
    if !defined?(@@build_number)
      svnversion = `svnversion #{RAILS_ROOT}/config`
      svnversion =~ /:?(\d+)[MS]?\s*$/
      @@build_number = $1
    end
    @@build_number
  end
  helper_method :build_number
  
  def imagine_build_number
    if !defined?(@@imagine_build_number)
      svnversion = `svnversion #{RAILS_ROOT}/config`
      svnversion =~ /:?(\d+)[MS]?\s*$/
      @@imagine_build_number = $1
    end
    @@imagine_build_number
  end
  helper_method :imagine_build_number
  
  def url_for_current(options = {})
    host_port = (request.ssl? ? 'https://' : 'http://') + request.host
    host_port += ":#{request.port}" if (!request.ssl? && request.port != 80) || (request.ssl? && request.port != 443)
    if options[:complete]
      return host_port + request.path
    else
      return request.path
    end
  end
  helper_method :url_for_current
  
  # Returns the first non-empty string in its arg list. Clearly, depends on nil_empty plugin.
  def first_non_empty(*args)
    while !args.empty?
      ret = args.shift
      return ret unless ret.to_s.empty?
    end
    return ''
  end
  
  # Determines whether the input string is a valid email address per RFC specification
  def valid_email_address?(addr)
    addr =~ /^([\w\d]+([\w\d\!\#\$\%\&\*\+\-\/\=\?\^\`\{\|\}\~\.]*[\w\d]+)*@([\w\d]+\.)+[\w]{2,})$/
  end
  
  
  #
  # For CMS integration
  #
  
  # valid options:
  # * :include_tags => 'tags, to, include'
  # * :exclude_tags => 'tags, to, exclude'
  def insert_object(name, type = :text, options = {}, html_options = {})
    extend ActionView::Helpers::TagHelper
    extend ActionView::Helpers::TextHelper
    
    @page_objects ||= {}
    
    key = "obj-#{type.to_s}-#{name.gsub(/[^\w]/, '_')}"
    case type.to_sym
    when :string
      content = substitute_placeholders(@page_objects[key] || '', @pg)
      content = erb_render(content)
      content = auto_link(content, :all, :target => '_blank') unless options[:disable_auto_link]
      content_tag :span, content, html_options
    when :text
      content = substitute_placeholders(@page_objects[key] || '', @pg)
      content = erb_render(content)
      content = auto_link(content, :all, :target => '_blank') unless options[:disable_auto_link]
      content_tag :div, content, html_options
    when :page_list
      @rss_feeds ||= []
      @rss_feeds << name
      
      case @page_objects["#{key}-style-display-as"]
      when 'calendar'
        pages = page_list_items(@pg, key, options).compact.uniq.
                  sort { |a,b| (a.position || 0) <=> (b.position || 0) }.
                  sort { |a,b| (b.article_date || b.published_date || Time.now) <=>
                               (a.article_date || a.published_date || Time.now) }
        render :partial => 'page_list_calendar', :locals => { :key => key, :pages => pages }
      else  # display as 'list'
        today = Time.mktime(Time.now.year, Time.now.month, Time.now.day)
        case @page_objects["#{key}-date-range"]
          when 'all'
          when 'past'
            options[:end_date] ||= today
          when 'future'
            options[:start_date] ||= today
          when 'custom'
            options[:start_date] ||= @page_objects["#{key}-date-range-custom-start"]
            options[:end_date] ||= @page_objects["#{key}-date-range-custom-end"]
        end
        
        pages = page_list_items(@pg, key, options).compact.uniq
        
        options[:wrapper_div] = true
        
        # make options specified in snippets and templates accessible to
        # page list segments and rss feeds
        @page_objects["#{key}-template"] = options[:template] if @page_objects["#{key}-template"].empty?
        
        render_page_list_segment(name, pages, options, html_options)
      end
    when :snippet
      @snippet = CmsSnippet.find_by_name(name)
      if @snippet
        erb_render(substitute_placeholders(@snippet.content, @pg))
      else
        'Could not find snippet "' + name + '" in the database.'
      end
    when :photo_gallery
      gallery_dir = File.join('images', 'content', @pg.path, File.basename(name))
      Dir.chdir(File.join(RAILS_ROOT, 'public'))
      all_images = Dir.glob("#{gallery_dir}/*.{jpg,jpeg,png,gif}")
      Dir.chdir(RAILS_ROOT)
      all_images.sort! { |a,b| File.basename(a).to_i <=> File.basename(b).to_i }
      images = all_images.reject { |img| img =~ /-thumb/ }
      thumbs = all_images.reject { |img| img !~ /-thumb/ }
      render_to_string :partial => 'photo_gallery', :locals => { :name => name, :images => images, :thumbs => thumbs }
    end
  end
  helper_method :insert_object
  
  def erb_render(content, safe_level = 3, rethrow_exceptions = false)
    return render_to_string(:inline => content)
    
    # output = nil
    # begin
    #   require 'erb'
    #   output = ERB.new(content.untaint, safe_level, '-').result(response.template.get_binding)
    # rescue Exception => e
    #   output = e.to_s.gsub(/</, '&lt;').gsub(/>/, '&gt;')
    #   throw e if rethrow_exceptions
    # end
    # # logger.debug output
    # output
  end
  
  def load_page_objects(obj_type = nil, name = nil)
    if params[:version].to_i > 0 && params[:version].to_i != @pg.published_version
      if is_logged_in_user?
        if user_has_permission?(:manage_cms)
          @pg.revert_to(params[:version].to_i)
        end
      else
        authenticate_user
        return false
      end
    elsif @pg.version != @pg.published_version
      @pg.revert_to(@pg.published_version)
    end
    
    @page_objects = HashObject.new
    conditions = [ 'cms_page_version = ?' ]
    cond_vars = [ @pg.version ]
    
    if obj_type
      conditions << 'obj_type = ?'
      cond_vars << obj_type
    end
    if name
      conditions << 'name = ?'
      cond_vars << name
    end
    
    @pg.objects.find(:all, :conditions => [ conditions.join(' and ') ].concat(cond_vars)).each do |obj|
      @page_objects["obj-#{obj.obj_type.to_s}-#{obj.name}"] = obj.content
    end
  end
  
  def page_list_items(pg, key, options = {})
    pages = []
    instance_tags_include = []
    instance_tags_exclude = []
    instance_tags_require = []
    
    conditions = [ 'cms_pages.published_version >= 0', 'cms_pages.published_date is not null', 'cms_pages.published_date < NOW()' ]
    cond_vars = []
    
    if options[:start_date]
      options[:start_date] = Time.parse(options[:start_date]) if options[:start_date].is_a? String
      conditions << 'cms_pages.article_date >= ?'
      cond_vars << options[:start_date]
    end
    if options[:end_date]
      options[:end_date] = Time.parse(options[:end_date]) if options[:end_date].is_a? String
      conditions << 'cms_pages.article_date < ?'
      cond_vars << (options[:end_date] + 1.day)
    end
    
    @page_objects["#{key}-sources-tag-count"] = @page_objects["#{key}-sources-tag-count"].to_i
    
    for i in 0...@page_objects["#{key}-sources-tag-count"]
      case @page_objects["#{key}-sources-tag#{i}-behavior"]
      when 'include'
        instance_tags_include << @page_objects["#{key}-sources-tag#{i}"]
      when 'exclude'
        instance_tags_exclude << @page_objects["#{key}-sources-tag#{i}"]
      when 'require'
        instance_tags_require << @page_objects["#{key}-sources-tag#{i}"]
      end
    end
    include_tags = instance_tags_include.map { |t| t.strip }.reject { |t| t.empty? }
    exclude_tags = instance_tags_exclude.map { |t| t.strip }.reject { |t| t.empty? }
    require_tags = instance_tags_require.map { |t| t.strip }.reject { |t| t.empty? }
    
    if include_tags.empty?
      include_tags = (options[:include_tags] || '').split(',').map { |t| t.strip }.reject { |t| t.empty? }
      include_tags.each do |t|
        i = @page_objects["#{key}-sources-tag-count"]
        @page_objects["#{key}-sources-tag#{i}"] = t
        @page_objects["#{key}-sources-tag#{i}-behavior"] = 'include'
        @page_objects["#{key}-sources-tag-count"] += 1
      end
    end
    if exclude_tags.empty?
      exclude_tags = (options[:exclude_tags] || '').split(',').map { |t| t.strip }.reject { |t| t.empty? }
      exclude_tags.each do |t|
        i = @page_objects["#{key}-sources-tag-count"]
        @page_objects["#{key}-sources-tag#{i}"] = t
        @page_objects["#{key}-sources-tag#{i}-behavior"] = 'exclude'
        @page_objects["#{key}-sources-tag-count"] += 1
      end
    end
    if require_tags.empty?
      require_tags = (options[:require_tags] || '').split(',').map { |t| t.strip }.reject { |t| t.empty? }
      require_tags.each do |t|
        i = @page_objects["#{key}-sources-tag-count"]
        @page_objects["#{key}-sources-tag#{i}"] = t
        @page_objects["#{key}-sources-tag#{i}-behavior"] = 'require'
        @page_objects["#{key}-sources-tag-count"] += 1
      end
    end
    
    # pull all folder content
    folders = []
    for i in 0...@page_objects["#{key}-sources-folder-count"].to_i
      folders << HashObject.new(:src => @page_objects["#{key}-sources-folder#{i}"].strip,
                                :expand_folders => @page_objects["#{key}-sources-folder#{i}-expand-folders"])
    end
    folders = folders.reject { |f| f.src.empty? }
    
    if folders.empty?
      folders = (options[:folders] || '').split(',').map do |f|
        bits = f.strip.split(':')
        
        obj = HashObject.new
        obj.src = bits[0]
        obj.expand_folders = 'true'
        
        while bit = bits.shift
          case bit
          when 'expand-folders'
            ;
          when 'no-expand-folders'
            obj.expand_folders = 'false'
          end
        end
        
        obj
      end
      folders = folders.reject { |f| f.src.empty? }
      
      @page_objects["#{key}-sources-folder-count"] = folders.size
      folders.each_with_index do |f, i|
        @page_objects["#{key}-sources-folder#{i}"] = f.src
        @page_objects["#{key}-sources-folder#{i}-expand-folders"] = f.expand_folders
      end
    end
    
    # exclude expired items if specified
    if @page_objects["#{key}-include-expired"]
      if @page_objects["#{key}-include-expired"] == 'false'
        conditions << '(cms_pages.expires = ? OR (cms_pages.expires = ? AND cms_pages.expiration_date >= ?))'
        cond_vars << false
        cond_vars << true
        cond_vars << Time.now
      end  
    end
    
    folders.each do |f|
      begin
        if f.expand_folders && f.expand_folders == 'false'
          f.src = f.src.slice(1...f.src.length) if f.src.slice(0,1) == '/'
          parent_page = CmsPage.find_by_path(f.src)
          pages.concat parent_page.children.find(:all, :include => [ :tags ], :conditions => [ conditions.join(' and ') ].concat(cond_vars))
        else
          if f.src == '/'
            pages.concat CmsPage.find(:all, :include => [ :tags ], :conditions => [ conditions.join(' and ') ].concat(cond_vars))
          else
            f.src = f.src.slice(1...f.src.length) if f.src.slice(0,1) == '/'
            fconditions = conditions.dup
            fconditions << 'path like ?'
            fcond_vars = cond_vars.dup
            fcond_vars << f.src+'/%'
            pages.concat CmsPage.find(:all, :include => [ :tags ], :conditions => [ fconditions.join(' and ') ].concat(fcond_vars))
          end
        end
      rescue Exception => e
        logger.debug e
      end
    end
    
    # pull all include tag content
    include_tags.each do |tag|
      pages.concat CmsPageTag.find_all_by_name(tag, :include => [ :page ], :conditions => [ conditions.join(' and ') ].concat(cond_vars)).map { |cpt| cpt.page }
    end
    
    # dump anything that has an excluded tag
    exclude_tags.each do |tag|
      pages.reject! { |page| page.tags.reject { |t| t.name != tag } != [] }
    end
    
    # dump anything that does not have a required tag
    require_tags.each do |tag|
      pages.reject! { |page| page.tags.reject { |t| t.name != tag } == [] }
    end
    
    if pg && (options[:exclude_current] === true || @page_objects["#{key}-exclude-current"] == 'true')
      pages.reject! { |page| page == pg }
    end
    
    # set some reasonable defaults in case the sort keys are nil
    pages.each { |pg| pg.article_date ||= Time.now; pg.position ||= 0; pg.title ||= '' }
    pri_sort_key = first_non_empty(@page_objects["#{key}-sort-first-field"], options[:primary_sort_key], 'article_date')
    pri_sort_dir = first_non_empty(@page_objects["#{key}-sort-first-direction"], options[:primary_sort_direction], 'asc')
    sec_sort_key = first_non_empty(@page_objects["#{key}-sort-second-field"], options[:secondary_sort_key], 'position')
    sec_sort_dir = first_non_empty(@page_objects["#{key}-sort-second-direction"], options[:secondary_sort_direction], 'asc')
    @page_objects["#{key}-sort-first-field"] ||= pri_sort_key
    @page_objects["#{key}-sort-first-direction"] ||= pri_sort_dir
    @page_objects["#{key}-sort-second-field"] ||= sec_sort_key
    @page_objects["#{key}-sort-second-direction"] ||= sec_sort_dir
    
    keys_with_dir = [ [ pri_sort_key, pri_sort_dir ], [ sec_sort_key, sec_sort_dir ] ]
    pages.sort! do |a,b|
      index = 0
      result = 0
      while result == 0 && index < keys_with_dir.size
        key = keys_with_dir[index][0]
        aval = a.send(key)
        bval = b.send(key)
        
        if !aval
          result = 1
        elsif !bval
          result = -1
        else
          result = aval <=> bval
        end
        
        result *= -1 if keys_with_dir[index][1] && keys_with_dir[index][1].downcase == 'desc'
        index += 1
      end
      
      result
    end
    
    offset = first_non_empty(@page_objects["#{key}-item-offset"], options[:item_offset], 0).to_i
    pages = pages[offset, pages.size] || []
    
    # randomize if requested
    randomize = first_non_empty(@page_objects["#{key}-use-randomization"], options[:use_randomization], 'false').to_s == 'true'
    random_pool_size = first_non_empty(@page_objects["#{key}-random-pool-size"], options[:random_pool_size], '').to_i
    if randomize
      if random_pool_size > 0
        pages = pages.first(random_pool_size)
      end
      
      n = pages.length
      for i in 0...n
        r = rand(n-1).floor
        pages[r], pages[i] = pages[i], pages[r]
      end
    end
    
    pages
  end
  
  def substitute_placeholders(html, page, extra_attributes = {})
    return html unless page
    
    temp = html.dup
    
    # mangle anything inside of an insert_object so that it won't be caught (yet)
    temp.gsub!(/(insert_object\()((?:\(.*?\)|[^()]*?)*)(\))/) do |match|
      one, two, three = $1, $2, $3
      one + two.gsub(/<#/, '<!#') + three
    end
    
    # first, extras passed in args
    extra_attributes.each do |k,v|
      temp.gsub!(/<#\s*#{k.to_s}\s*#>/, v.to_s)
    end
    
    # next, page object attributes and template options (from page properties)
    page.objects.find(:all, :conditions => [ "obj_type = 'attribute'" ]).each do |obj|
      temp.gsub!(/<#\s*#{obj.name}\s*#>/, (obj.content || '').to_s)
    end
    page.objects.find(:all, :conditions => [ "obj_type = 'option'" ]).each do |obj|
      temp.gsub!(/<#\s*option_#{obj.name.gsub(/[^\w\d]/, '_')}\s*#>/, obj.content || '')
    end
    
    # path is kind of a special case, we like to see it with a leading /
    temp.gsub!(/<#\s*path\s*#>/, '/' + (page.path || ''))
    
    # substitute tags in a helpful way
    temp.gsub!(/<#\s*tags\s*#>/, page.tags.map { |t| t.name }.join(', '))
    temp.gsub!(/<#\s*tags_as_css_classes\s*#>/, page.tags_as_css_classes)
    
    # use full date/time format for created_on and updated_on
    temp.gsub!(/<#\s*created_on\s*#>/, "#{page.created_on.strftime('%a')} #{date_to_str(page.created_on)} #{time_to_str(page.created_on)}") if page.created_on
    temp.gsub!(/<#\s*updated_on\s*#>/, "#{page.updated_on.strftime('%a')} #{date_to_str(page.updated_on)} #{time_to_str(page.updated_on)}") if page.updated_on
    
    # finally, toss in the rest of the generic class attributes
    page.attributes.map { |c| c.first }.each do |attr|
      begin
        val = page.send(attr.downcase.underscore)
        case val.class.to_s
        when 'Time'
          val = val.strftime("(%a) ") + val.strftime("%B ") + val.day.to_s + val.strftime(", %Y")
        when 'NilClass'
          val = ''
        else
          # logger.error "#{attr} (#{val.class}): #{val}"
        end
      rescue
        # val = '<!-- attribute not found -->'
        val = ''
      end
      temp.gsub!(/<#\s*#{attr}\s*#>/, val.to_s)
    end
    # temp.gsub!(/<#\s*(.*?)\s*#>/, "<!-- attribute not found -->")
    temp.gsub!(/<#\s*(.*?)\s*#>/, '')
    
    # unmangle mangled stuff
    temp.gsub!(/(insert_object\()((?:\(.*?\)|[^()]*?)*)(\))/) do |match|
      one, two, three = $1, $2, $3
      one + two.gsub(/<!#/, '<#') + three
    end
    
    temp
  end
  helper_method :substitute_placeholders
  
  def template_option(name, type = :string)
    return nil unless @pg
    
    @template_options ||= {}
    @template_options[name] = type
    
    key = name.gsub(/[^\w\d]/, '_')
    obj = @pg.objects.find_by_name("#{type}-#{key}", :conditions => [ "obj_type = 'option'" ])
    return nil unless obj
    
    case type
    when :checkbox
      obj.content == "1"
    else
      obj.content
    end
  end
  helper_method :template_option
  
  def render_page_list_segment(name, pages, options = {}, html_options = {})
    extend ActionView::Helpers::TagHelper
    extend ActionView::Helpers::TextHelper
    extend ActionView::Helpers::JavaScriptHelper
    extend ActionView::Helpers::PrototypeHelper
    
    key = "obj-page_list-#{name.gsub(/[^\w]/, '_')}"
    
    offset = first_non_empty(params[:offset], 0).to_i
    limit = first_non_empty(@page_objects["#{key}-max-item-count"], options[:item_count], pages.size).to_i
    limit = 1 if limit < 1
    page_subset = pages[offset, limit] || []
    
    content = ''
    content << substitute_placeholders(first_non_empty(@page_objects["#{key}-header"], options[:header]), @pg,
                                       :count => page_subset.size, :total => pages.size,
                                       :rss_feed_url => (@pg && @pg.id ? url_for(:action => 'rss_feed', :page_id => @pg.id,
                                                                       :page_list_name => name) : nil))
    if page_subset.empty?
      content << substitute_placeholders(first_non_empty(@page_objects["#{key}-empty_message"],
                                                         options[:empty_message],
                                                         'No pages found.'), @pg)
    else
      page_subset.each_with_index do |page, index|
        content << substitute_placeholders(first_non_empty(@page_objects["#{key}-template"], options[:template], ''), page,
                                           :index => index+1, :count => page_subset.size, :total => pages.size)
      end
    end
    
    content << substitute_placeholders(first_non_empty(@page_objects["#{key}-footer"], options[:footer]), @pg,
                                       :count => page_subset.size, :total => pages.size,
                                       :rss_feed_url => (@pg && @pg.id ? url_for(:action => 'rss_feed', :page_id => @pg.id,
                                                                       :page_list_name => name) : nil))
    
    num_segments = (pages.size.to_f / limit).ceil
    if @page_objects["#{key}-use-pagination"].to_i == 1 && num_segments > 1
      content << '<table style="margin-top: 4px;" align="right" cellpadding="0" cellspacing="0" border="0"><tr valign="bottom">'
      content << '<td>Page:&nbsp;</td>'
      num_segments.times do |seg|
        start = seg * limit
        content << "<td><div"
        if offset >= start && offset < (start + limit)
          content << " class=\"page_list_segment page_list_segment_selected\""
        else
          content << " class=\"page_list_segment\""
          content << " onmouseover=\"this.className = 'page_list_segment page_list_segment_selected'\""
          content << " onmouseout=\"this.className = 'page_list_segment'\""
          content << " onclick=\"this.style.cursor = 'wait';"
          content << remote_function(:update => key, :url => { :content_path => @pg.path.split('/').concat([ 'segment', start.to_s, name ]) })
          content << "; return false;\""
        end
        content << ">#{seg+1}</div></td>"
      end
      content << '</tr></table>'
    end
    
    if options[:wrapper_div]
      content_tag :div, erb_render(content), html_options.update(:id => key)
    else
      erb_render(content)
    end
  end
  
  def breadcrumbs(options = {})
    # only works on CCS pages
    if @pg
      separator = options.delete(:separator) || ' &raquo; '
      link_class = options.delete(:link_class)
      
      pg = @pg
      ret = pg.title
      
      while pg = pg.parent
        if pg.published_version >= 0
          ret = "<a href=\"/#{pg.path}\" class=\"#{link_class}\">#{pg.title}</a>" + separator + ret
        end
      end
      
      return ret
    else
      return ''
    end
  end
  helper_method :breadcrumbs
  
  def garbage_collect
    GC.start
  end
  
  
  protected
  
  # Takes an Exception as its argument and sends a descriptive error email to the developers
  # (ErrorEmailRecipients), including stack trace, params, session data and server environment.
  #
  # log_error is already called by the default exception handler, but if you rescue any
  # exceptions, you must either re-throw the exception or manually call log_error if want to
  # receive the error report.
  def log_error(exception) 
    super(exception)
    
    begin
      Mailer.deliver_exception_report(exception, clean_backtrace(exception),
                                      session.instance_variable_get("@data"),
                                      params, @request.env)
    rescue => e
      logger.error(e)
    end unless (request.host rescue '') == 'localhost'
  end
end
