class DeviseTokenAuthCreateUsers < ActiveRecord::Migration[6.1]
  def change
    
    create_table(:users) do |t|
      ## Required
      t.string :provider, :null => false, :default => "email"
      t.string :uid, :null => false, :default => ""

      ## Database authenticatable
      t.string :encrypted_password, :null => false, :default => ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.boolean  :allow_password_change, :default => false

      ## Rememberable
      t.datetime :remember_created_at

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, :default => 0, :null => false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## User Info
      t.string :first_name
      t.string :last_name
      t.text :address
      t.string :email
      t.references :supervisor, null: true, index: true, foreign_key: {to_table: :users}
      t.date :hired_at
      t.text :web_address
      t.integer :status
      t.integer :pay_type
      t.boolean :service_provider
      t.integer :timing_type
      t.integer :hours_per_week
      t.date :terminated_at
      t.boolean :ot_exempt
      t.string :phone_ext
      t.integer :term_type
      t.integer :residency
      t.date :status_date
      t.string :driving_license
      t.date :driving_license_expires_at
      t.date :date_of_birth
      t.string :ssn
      t.string :badge_id
      t.integer :badge_type

      ## Tokens
      t.json :tokens

      t.timestamps
    end

    add_index :users, :email,                unique: true
    add_index :users, %i[uid provider],     unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
  end
end
