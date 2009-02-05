class ActionController::Base
  prepend_before_filter :connect_to_hospital_database
  
  # manually establish a connection to the proper database
  def connect_to_hospital_database
    @hospital = nil
    
    # request is first priority
    if params[:hospital_code]
      if session[:hospital_key] && session[:hospital_key] != params[:hospital_code]
        reset_session
      end
      @hospital = Master::Hospital.find_by_code(params[:hospital_code])
    end
    # try hostname if we don't already have a key in the session
    unless session[:hospital_key]
      if !@hospital && (request.host rescue '') =~ /^([-\w\d]+)/
        @hospital = Master::Hospital.find_by_code($1)
      end
      if !@hospital
        @hospital = Master::Hospital.find_by_host request.host
      end
    end
    
    if @hospital
      if session[:hospital_key] != @hospital.key
        session[:hospital_key] = @hospital.key
        session[:hospital_name] = @hospital.name
        session[:hospital_code] = @hospital.code
        
        session[:hospital_logo_file] = @hospital.logo_file if File.exists?(@hospital.logo_file)
      end
    end
    
    if session[:hospital_key]
      @hospital ||= Master::Hospital.find_by_code(session[:hospital_key])
      ActiveRecord::Base.connect_to_hospital session[:hospital_key]
      return true
    end
    
    # if we don't issue an establish_connection by now, return an error
    render :text => "Hospital not found, please make sure the URL you entered is correct.", :status => 404 and return false
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
      
      def connect_to_test
        config = ActiveRecord::Base.configurations['test']
        self.establish_connection(
          :adapter  => config['adapter'],
          :database => config['database'],
          :host     => config['host'],
          :username => config['username'],
          :password => config['password']
        )
        ENV['RAILS_HOSPITAL'] = "test"
      end
      
      
      def connect_to_hospital(hospital_key = nil)
        hospital_key ||= ENV['RAILS_HOSPITAL']
        throw Exception.new('No hospital selected') if !hospital_key
        
        config = ActiveRecord::Base.configurations[RAILS_ENV]
        self.establish_connection(
          :adapter  => config['adapter'],
          :database => config['database'] + '_' + hospital_key,
          :host     => config['host'],
          :username => config['username'],
          :password => config['password']
        )
        
        ENV['RAILS_HOSPITAL'] = hospital_key
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
        if ENV['RAILS_HOSPITAL'] == 'master'
          Base.connect_to_master
        elsif ENV['RAILS_HOSPITAL'] == 'sessions'
          # do nothing
        elsif ENV['RAILS_HOSPITAL'] == 'test'
          # do nothing
        else
          Base.connect_to_hospital ENV['RAILS_HOSPITAL']
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
      return unless ENV['RAILS_HOSPITAL'] == 'master'
      super(direction)
    end
  end
end

class SessionsMigration < ActiveRecord::Migration
  class << self
    def migrate(direction)
      return unless ENV['RAILS_HOSPITAL'] == 'sessions'
      super(direction)
    end
  end
end

class HospitalMigration < ActiveRecord::Migration
  class << self
    def migrate(direction)
      return if ENV['RAILS_HOSPITAL'] == 'master' || ENV['RAILS_HOSPITAL'] == 'sessions'
      super(direction)
    end
  end
end
