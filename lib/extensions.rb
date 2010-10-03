class ActionController::Base
  prepend_before_filter :connect_to_hospital_database
  
  # manually establish a connection to the proper database
  def connect_to_hospital_database
    @hospital = nil
    
    hospital_config_file = RAILS_ROOT + "/config/hospital.yml"
    hospital = YAML::parse(File.open(hospital_config_file))
    :session['hospital_name'] = hospital['hospital_name'].value
    :session['hospital_logo_file'] = hospital['hospital_logo_file'].value
    
    @hospital = Master::Hospital.new
    @hospital.logo_file = hospital['hospital_logo_file'].value
    
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
