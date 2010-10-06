module RedHillConsulting
  module SchemaDefining
    module Schema
      def self.extended(base)
        class << base
          attr_accessor :defining
          alias :defining? :defining

          alias_method :define_without_run_state, :define unless method_defined?(:define_without_run_state)
          alias_method :define, :define_with_run_state
        end
      end

      def define_with_run_state(info={}, &block)
        begin
          self.defining = true
          define_without_run_state(info, &block)
        ensure
          self.defining = false
        end
      end
    end
  end
end
