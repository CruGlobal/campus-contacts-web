class AddPreviewToImports < ActiveRecord::Migration
  def change
    add_column :imports, :preview, :text, after: 'header_mappings'
  end
end
