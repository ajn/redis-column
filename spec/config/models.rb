class TestModel < ActiveRecord::Base; end

class DescriptionInRedisModel < TestModel
  redis_col :description
end

