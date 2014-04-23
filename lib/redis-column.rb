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
      # Assign redis_columns
      after_initialize :assign_redis_columns
      # Save the columns after_save
      after_save :save_redis_columns!
      # Delete the columns after_destroy
      after_destroy :delete_redis_columns!
    end

    module ClassMethods

      # Setup a redis column
      def redis_column column_name
        self.redis_columns += [column_name]
        define_method(column_name) { @attributes[column_name.to_s] }
        define_method("#{column_name}=") {|val| @attributes[column_name.to_s] = val }
      end
      alias_method :redis_col, :redis_column

    end

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

    # Delete value from Redis
    def delete_redis_attribute column_name
      redis_instance.del(redis_key(column_name))
    end

    # Assigns the values from Redis unless already specified
    def assign_redis_columns
      redis_columns.each do |column_name|
        send("#{column_name}=", read_redis_attribute(column_name)) unless has_attribute?(column_name.to_s)
      end
    end

    # Save all values back to Redis
    def save_redis_columns!
      redis_columns.each do |column_name|
        write_redis_attribute column_name, read_attribute(column_name)
      end
    end

    # Delete all values in Redis
    def delete_redis_columns!
      redis_columns.each do |column_name|
        delete_redis_attribute column_name
      end
    end

  end
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send :include, RedisColumn::Record
end