RedisColumn
===========

Seamlessly extend your AR model with Redis

The RedisColumn gem allows for the seamless integration of Redis within your ActiveRecord model in order to store heavy objects away from tables with a lot of rows.

Installation
------------

    gem install redis-column
  
Usage
-----

Within an initializer:

    RedisColumn.config = YAML.load_file(Rails.root.join('config/redis.yml'))[:development]

  
Within your model:

    class Page < ActiveRecord::Base
      redis_column :body
    end

    
    