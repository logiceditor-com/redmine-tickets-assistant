class CreateTicketsAssistantSettings < ActiveRecord::Migration
  def self.up
    create_table :tickets_assistant_settings do |t|

      t.column :exclude_reassign_user_ids, :string

      t.column :reassign_user_id, :integer

    end
  end

  def self.down
    drop_table :tickets_assistant_settings
  end
end
