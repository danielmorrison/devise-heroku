ActiveRecord::Schema.define do
  create_table "users", force: true do |t|
    t.string   "email",                 default: "",    null: false
    t.string   "encrypted_password",    default: "",    null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end
end
