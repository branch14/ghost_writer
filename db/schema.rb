# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110815111057) do

  create_table "assignments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "documents", :force => true do |t|
    t.string   "type"
    t.string   "attachable_type"
    t.integer  "attachable_id"
    t.text     "comment"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locales", :force => true do |t|
    t.string   "code"
    t.string   "title"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locales", ["code", "project_id"], :name => "index_locales_on_code_and_project_id"

  create_table "projects", :force => true do |t|
    t.string   "title"
    t.string   "permalink"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "api_key"
  end

  add_index "projects", ["permalink"], :name => "index_projects_on_permalink"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "tokens", :force => true do |t|
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "complex"
    t.text     "notes"
    t.string   "ancestry"
    t.integer  "ancestry_depth"
    t.string   "key"
    t.string   "full_key"
    t.text     "annotation"
  end

  add_index "tokens", ["ancestry"], :name => "index_tokens_on_ancestry"
  add_index "tokens", ["ancestry_depth"], :name => "index_tokens_on_depth"
  add_index "tokens", ["full_key"], :name => "index_tokens_on_full_key"
  add_index "tokens", ["project_id"], :name => "index_tokens_on_hashed_and_project_id"
  add_index "tokens", ["project_id"], :name => "index_tokens_on_raw_and_project_id"

  create_table "translations", :force => true do |t|
    t.text     "content",      :limit => 255
    t.integer  "hits_counter",                :default => 0
    t.integer  "token_id"
    t.integer  "locale_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                      :default => true
    t.integer  "miss_counter",                :default => 0
  end

  add_index "translations", ["content", "locale_id"], :name => "index_translations_on_content_and_locale_id"
  add_index "translations", ["token_id", "locale_id"], :name => "index_translations_on_token_id_and_locale_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
