module RedHillConsulting
  module TransactionalMigrations
    module Migration
      def self.extended(base)
        class << base
          alias_method :migrate_without_transactions, :migrate unless method_defined?(:migrate_without_transactions)
          alias_method :migrate, :migrate_with_transactions
        end
      end

      def migrate_with_transactions(direction)
        ActiveRecord::Base.transaction { migrate_without_transactions(direction) }
      end
    end
  end
end
