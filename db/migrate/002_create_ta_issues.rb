class CreateTaIssues < ActiveRecord::Migration
  def self.up
    create_table :ta_issues do |t|

      t.column :issue_id, :integer

    end
  end

  def self.down
    drop_table :ta_issues
  end
end
