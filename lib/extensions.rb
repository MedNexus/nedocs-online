class ActionController::Base
  prepend_before_filter :connect_to_institution_database
  
  # manually establish a connection to the proper database
  def connect_to_institution_database
    @institution = nil
    
    # request is first priority
    if params[:institution_code]
      if session[:institution_key] && session[:institution_key] != params[:institution_code]
        reset_session
      end
      @institution = Master::Institution.find_by_code(params[:institution_code])
    end
    # try hostname if we don't already have a key in the session
    unless session[:institution_key]
      if !@institution && (request.host rescue '') =~ /^([-\w\d]+)/
        @institution = Master::Institution.find_by_code($1)
      end
      if !@institution
        @institution = Master::Institution.find_by_host request.host
      end
    end
    
    if @institution
      if session[:institution_key] != @institution.key
        session[:institution_key] = @institution.key
        session[:institution_name] = @institution.name
        session[:institution_code] = @institution.code
        
        session[:institution_logo_file] = @institution.logo_file if File.exists?(@institution.logo_file)
      end
    end
    
    if session[:institution_key]
      @institution ||= Master::Institution.find_by_code(session[:institution_key])
      ActiveRecord::Base.connect_to_institution session[:institution_key]
      return true
    end
    
    # if we don't issue an establish_connection by now, return an error
    render :text => "Institution not found, please make sure the URL you entered is correct.", :status => 404 and return false
  end
end

module ActiveRecord
  class Base
    class << self
      
      def connect_to_master
        @@master_config ||= ActiveRecord::Base.configurations['master_' + RAILS_ENV]
        self.establish_connection(
          :adapter  => @@master_config['adapter'],
          :database => @@master_config['database'],
          :host     => @@master_config['host'],
          :username => @@master_config['username'],
          :password => @@master_config['password']
        )
      end
      
      def connect_to_institution(institution_key = nil)
        institution_key ||= ENV['RAILS_INSTITUTION']
        throw Exception.new('No institution selected') if !institution_key
        
        config = ActiveRecord::Base.configurations[RAILS_ENV]
        self.establish_connection(
          :adapter  => config['adapter'],
          :database => config['database'] + '_' + institution_key,
          :host     => config['host'],
          :username => config['username'],
          :password => config['password']
        )
        
        ENV['RAILS_INSTITUTION'] = institution_key
      end
      
      def connect_to_sessions
        config = ActiveRecord::Base.configurations[RAILS_ENV]
        self.establish_connection(
          :adapter  => config['adapter'],
          :database => config['database'],
          :host     => config['host'],
          :username => config['username'],
          :password => config['password']
        )
      end
    end
  end
  
  class Migrator
    class << self
      alias_method :old_migrate, :migrate
      def migrate(migrations_path, target_version = nil)
        if ENV['RAILS_INSTITUTION'] == 'master'
          Base.connect_to_master
        elsif ENV['RAILS_INSTITUTION'] == 'sessions'
          # do nothing
        else
          Base.connect_to_institution ENV['RAILS_INSTITUTION']
        end
        
        old_migrate(migrations_path, target_version)
      end
    end
  end
end

class CGI::Session::ActiveRecordStore::Session < ActiveRecord::Base
  self.connection = self.connect_to_sessions
end

class MasterMigration < ActiveRecord::Migration
  class << self
    def migrate(direction)
      return unless ENV['RAILS_INSTITUTION'] == 'master'
      super(direction)
    end
  end
end

class SessionsMigration < ActiveRecord::Migration
  class << self
    def migrate(direction)
      return unless ENV['RAILS_INSTITUTION'] == 'sessions'
      super(direction)
    end
  end
end

class InstitutionMigration < ActiveRecord::Migration
  class << self
    def migrate(direction)
      return if ENV['RAILS_INSTITUTION'] == 'master' || ENV['RAILS_INSTITUTION'] == 'sessions'
      super(direction)
    end
  end
end
