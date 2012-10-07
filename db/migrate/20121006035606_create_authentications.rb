class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid
      t.string :oauth_token
      t.datetime :oauth_token_at      
      t.text :data

      t.timestamps
    end
  end
end
