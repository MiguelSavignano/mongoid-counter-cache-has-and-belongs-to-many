module Mongoid
  module CounterCacheHasAndBelongsToMany
    extend ActiveSupport::Concern
    module ClassMethods

      #override
      def has_and_belongs_to_many(field_name, options={})
        return super(field_name, options) unless options[:counter_cache]
        field :"#{field_name}_count", type: Integer, default: 0
        options = build_after_add_after_remove_callbacks(field_name, options).merge(options)
        super field_name, options
      end

      private
      def build_after_add_after_remove_callbacks(field_name, options={})
        names = {
          field_name_count:     :"#{field_name}_count",
          inverse_counter_name: :"#{options[:inverse_of]}_count"
        }
        {
          after_add: function_set_counters(1, names),
          after_remove: function_set_counters(-1, names)
        }
      end

      def function_set_counters(decrement_or_increment, field_name_count:, inverse_counter_name:)
        ->(document, ducument_added_or_remove){
          document.inc(:"#{field_name_count}" => decrement_or_increment)
          ducument_added_or_remove.inc(:"#{inverse_counter_name}" => decrement_or_increment)
        }
      end

    end

  end
end
