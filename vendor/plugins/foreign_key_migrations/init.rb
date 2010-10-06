ActiveRecord::Migrator.send(:extend, RedHillConsulting::ForeignKeyMigrations::Migrator)
ActiveRecord::ConnectionAdapters::AbstractAdapter.send(:include, RedHillConsulting::ForeignKeyMigrations::AbstractAdapter)
ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, RedHillConsulting::ForeignKeyMigrations::TableDefinition)
ActiveRecord::ConnectionAdapters::ColumnDefinition.send(:include, RedHillConsulting::ForeignKeyMigrations::ColumnDefinition)
