# Copyright (c) 2006 Bigger Bird Creative, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#
# Not sure this is necessary, but for the 6 lines stolen from
# ActiveRecord::Base.find, marked with trailing #s:
#
# Copyright (c) 2004 David Heinemeier Hansson
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 

require 'active_record'

module ImaginePlugins
  module Acts # :nodoc:
    module SoftDeletable # :nodoc:
      
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_soft_deletable
          class_eval do
            extend ImaginePlugins::Acts::SoftDeletable::SingletonMethods
          end
          include ImaginePlugins::Acts::SoftDeletable::InstanceMethods
        end
      end
      
      module SingletonMethods
        def find(*args)
          options = extract_options_from_args!(args)          #
          
          include_deleted = options.delete(:include_deleted)
          only_deleted = options.delete(:only_deleted)
          
          validate_find_options(options)                      #
          set_readonly_option!(options)                       #
          
          scope = {}
          if only_deleted
            scope = { :find => { :conditions => 'deleted = 1' } }
          elsif !include_deleted
            scope = { :find => { :conditions => 'deleted = 0' } }
          end
          
          with_scope(scope) do
            case args.first
              when :first then find_initial(options)          #
              when :all   then find_every(options)            #
              else             find_from_ids(args, options)   #
            end
          end
        end
        
        def soft_delete(id)
          if id.kind_of? Array
            id.each do |i|
              soft_delete_all([ "#{primary_key} IN (?)", i ])
            end
          else
            soft_delete_all([ "#{primary_key} IN (?)", id ])
          end
        end
        
        def soft_delete_all(conditions = nil)
          sql = "UPDATE #{table_name} SET deleted = 1 "
          add_conditions!(sql, conditions, scope(:find))
          connection.update(sql, "#{name} soft delete all")
        end
        
        def undelete(id)
          if id.kind_of? Array
            id.each do |i|
              undelete_all([ "#{primary_key} IN (?)", i ])
            end
          else
            undelete_all([ "#{primary_key} IN (?)", id ])
          end
        end
        
        def undelete_all(conditions = nil)
          sql = "UPDATE #{table_name} SET deleted = 0 "
          add_conditions!(sql, conditions, scope(:find))
          connection.update(sql, "#{name} soft delete all")
        end
      end
      
      module InstanceMethods
        def soft_delete
          self.deleted = 1
          self.deleted_on = Time.now
          save
        end
        
        def undelete
          self.deleted = 0
          self.deleted_on = nil
          save
        end
      end
      
    end
  end
end

# Make class methods available
ActiveRecord::Base.send(:include, ImaginePlugins::Acts::SoftDeletable)


# more fixes for calculations
module ActiveRecord
  module Calculations #:nodoc:
    module ClassMethods
      def calculate_with_soft_deletable(operation, column_name, options = {})
        scope = {}
        
        if self.respond_to?(:soft_delete)
          include_deleted = options.delete(:include_deleted)
          only_deleted = options.delete(:only_deleted)
          
          if only_deleted
            scope = { :find => { :conditions => 'deleted = 1' } }
          elsif !include_deleted
            scope = { :find => { :conditions => 'deleted = 0' } }
          end
        end
        
        with_scope(scope) do
          return calculate_without_soft_deletable(operation, column_name, options)
        end
      end
      alias_method_chain :calculate, :soft_deletable
    end
  end
end
