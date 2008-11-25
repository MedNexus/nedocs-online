module ReflectConnectPlugins
  module Acts # :nodoc:
    module Archivable # :nodoc:
      
      def self.included(mod)
        mod.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_archivable
          class_eval do
            extend ReflectConnectPlugins::Acts::Archivable::SingletonMethods
          end
          include ReflectConnectPlugins::Acts::Archivable::InstanceMethods
        end
      end
      
      module SingletonMethods
        def list
          list_unarchived
        end
        
        def list_unarchived
          find(:all, :conditions => ["archived = 0"], :order => ["name ASC"])
        end
        
        def list_archived
          find(:all, :conditions => ["archived = 1"], :order => ["name ASC"])
        end
      end
      
      module InstanceMethods
        def archive!
          update_attribute(:archived, 1)
        end
        
        def restore!
          update_attribute(:archived, 0)
        end
      end
      
    end
  end
end

# Make class methods available
ActiveRecord::Base.send(:include, ReflectConnectPlugins::Acts::Archivable)
