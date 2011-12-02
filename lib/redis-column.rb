require "active_record"
require "redis"
require File.dirname(__FILE__) + "/redis-column/version"

module RedisColumn
  
  # Returns the current Redis configuration
  def self.config
    @@config ||= {}
  end
  
  # Sets the Redis configuration
  def self.config= hash
    @@config = hash 
  end
  
  # Active Redis connection
  def self.redis_instance
    @@redis_instance ||= Redis.new(config)
  end
  
  module Record
    extend ActiveSupport::Concern

    included do
      # Set up the class attribute that must be available to all subclasses.
      class_attribute :redis_columns
      self.redis_columns = []
      # Allow the instance access to this class attributes
      delegate :redis_columns, :to => "self.class"
      # Allow the instance access to RedisColumn.redis_instance
      delegate :redis_instance, :to => "RedisColumn"
      # Save the columns after 
      after_save :save_redis_columns!
      # Boosh!
      alias_method_chain :attributes, :redis_columns
    end

    module ClassMethods
      
      # Setup a redis column
      def redis_column column_name
        self.redis_columns += [column_name]
        attr_writer column_name
        define_method column_name do # read the attribute or find from Redis and set to instance var
          send(:instance_variable_get, "@#{column_name}") || send("#{column_name}=", read_redis_attribute(column_name))
        end
      end
      alias_method :redis_col, :redis_column
      
    end
    
    module InstanceMethods
      
      # Returns the key to be used in Redis
      def redis_key column_name
        "#{self.class.model_name.i18n_key}:#{self.id}:#{column_name}"
      end
      
      # Read from Redis and unserialise
      def read_redis_attribute column_name
        val = redis_instance.get(redis_key(column_name))
        YAML.load(val) unless val.nil?
      end
      
      # Serialise and write to Redis
      def write_redis_attribute column_name, val
        redis_instance.set(redis_key(column_name), val.to_yaml) and return val
      end
      
      # Returns both the AR attributes and the Redis attributes in one hash
      def attributes_with_redis_columns
        _attributes = attributes_without_redis_columns.with_indifferent_access
        redis_columns.inject(_attributes) do |res, column_name|
          res.merge(column_name => send(column_name))
        end
      end
      
      # Save all values back to Redis
      def save_redis_columns!
        redis_columns.each do |column_name|
          write_redis_attribute column_name, send(column_name)
        end
      end
      
    end
  end
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send :include, RedisColumn::Record
end