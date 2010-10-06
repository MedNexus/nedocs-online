module RedHillConsulting
  module ForeignKeyMigrations
    module AbstractAdapter
      def add_foreign_key(foreign_table_name, foreign_column_names, primary_table_name, primary_column_names)
        execute "ALTER TABLE #{foreign_table_name.to_s} ADD FOREIGN KEY (#{Array(foreign_column_names).join(", ")}) REFERENCES #{ActiveRecord::Migrator.proper_pluralized_table_name(primary_table_name)} (#{Array(primary_column_names).join(", ")});"
      end
    end
    
    module Migrator
      def proper_pluralized_table_name(table_name)
        proper_table_name(pluralized_table_name(table_name))
      end
      
      def pluralized_table_name(table_name)
        ActiveRecord::Base.pluralize_table_names ? table_name.to_s.pluralize : table_name
      end
    end

    module TableDefinition
      def self.included(base)
        base.class_eval do
          alias_method :column_without_fk, :column unless method_defined?(:column_without_fk)
          alias_method :column, :column_with_fk
        end
      end

      def column_with_fk(name, type, options = {})
        column_without_fk(name, type, options)
        self[name].references = options[:references] if options.has_key?(:references)
        self
      end
    end

    module ColumnDefinition
      def self.included(base)
        base.class_eval do
          alias_method :to_sql_without_fk, :to_sql unless method_defined?(:to_sql_without_fk)
          alias_method :to_sql, :to_sql_with_fk
          alias :to_s :to_sql
        end
      end

      attr_accessor :references

      def to_sql_with_fk
        return to_sql_without_fk if ActiveRecord::Schema.defining?
        
        if defined?(@references)
          table_name = @references
        elsif name.to_s =~ /^(.*)_id$/
          table_name = ActiveRecord::Migrator.pluralized_table_name($1)
        end
        
        table_name ? "#{to_sql_without_fk}, FOREIGN KEY (#{name}) REFERENCES #{ActiveRecord::Migrator.proper_table_name(table_name)} (id)" : to_sql_without_fk
      end
    end
  end
end
