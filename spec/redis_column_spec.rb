require 'spec_helper'

describe TestModel do
  it { TestModel.should respond_to(:redis_column) }
  it { TestModel.should respond_to(:redis_col) }
  it { TestModel.should respond_to(:redis_columns) }
  
  describe 'redis_column' do
    context 'with no arguments' do
      it "should raise an argument error" do
        lambda { TestModel.redis_column }.should raise_error(ArgumentError)
      end
    end
    
    context "with a column_name" do
      it "should add the column_name to the redis_columns array" do
        TestModel.redis_columns.should == []
        TestModel.redis_column :body
        TestModel.redis_columns.should == [:body]
      end
      
      it "should add an accessor for the column_name" do
        TestModel.redis_column :body
        TestModel.new.should respond_to(:body)
        TestModel.new.should respond_to(:body=)
      end
    end
  end
end

describe DescriptionInRedisModel do
  it "should have a redis_column for the description attribute" do
    DescriptionInRedisModel.redis_columns.should == [:description]
  end
  
  it "should have a default redis key of '<model_name>:<id>:<column_name>' for the description attribute" do
    instance = DescriptionInRedisModel.create
    instance.redis_key(:description).should == "description_in_redis_model:#{instance.id}:description"
  end
  
  context "before save" do
    it "should not have stored the description in redis" do
      instance = DescriptionInRedisModel.new(description: "A looong description")
      RedisColumn.redis_instance.get("description_in_redis_model:#{instance.id}:description").should_not be("A looong description".to_yaml)
    end
  end
  
  context "when saving" do
    it "should store the description in redis, with the key '<model_name>:<id>:<column_name>'" do
      instance = DescriptionInRedisModel.create!(description: "A looong description")
      RedisColumn.redis_instance.get("description_in_redis_model:#{instance.id}:description").should == "A looong description".to_yaml
    end
  end
  
  context "when saved" do
    before do
      @instance = DescriptionInRedisModel.create!(description: "A looong description")
    end
    
    it "should retrive the description from redis, with the key '<model_name>:<id>:<column_name>'" do
      @instance = DescriptionInRedisModel.find(@instance.id)
      @instance.description.should == "A looong description"
    end
    
    it "should return the redis_columns within :attributes" do
      @instance.attributes.should have_key('string')
      @instance.attributes.should have_key('description')
    end
    
    context "and finding" do
      
      before do
        @instance = DescriptionInRedisModel.find(@instance.id)
      end
      
      it "should set the redis_columns after find" do
        @instance.attributes['description'].should == "A looong description"
        @instance.description.should == "A looong description"
      end
    end

    context "and destroying" do
      before do
        @instance.destroy
      end
      
      it "should also delete the description from redis" do
        RedisColumn.redis_instance.get("description_in_redis_model:#{@instance.id}:description").should be_blank
      end
      
    end
    
    context "and duping" do
      
      before do
        @new_instance = @instance.dup
        @new_instance.save!
        @new_instance = DescriptionInRedisModel.find(@new_instance.id)
      end
      
      it { @new_instance.should_not == @instance }
      
      it "should set the redis_columns after find" do
        @new_instance.attributes['description'].should == "A looong description"
        @new_instance.description.should == "A looong description"
      end
    end
  end
  
end