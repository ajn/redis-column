ActiveRecord::Schema.define :version => 0 do
  create_table "test_models", :force => true do |t|
    t.integer  "integer"
    t.datetime "created_at"
    t.string   "type", :default => 'TestModel'
    t.string   "string"
  end

  add_index "test_models", ["integer"], :name => "index_test_models_on_integer"
  add_index "test_models", ["created_at"], :name => "index_test_models_on_created_at"
  add_index "test_models", ["type"], :name => "index_test_models_on_type"
end