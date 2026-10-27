class AddFormIdIntToCxCollectionDetails < ActiveRecord::Migration[8.1]
  def change
    add_column :cx_collection_details, :form_id_int, :integer

    up_only do
      execute <<-SQL
        UPDATE cx_collection_details 
        SET form_id_int = CASE 
          -- Ensure the text strictly contains only numbers (handling spaces)
          WHEN trim(form_id) ~ '^[0-9]+$' 
          THEN trim(form_id)::integer
          -- Default to NULL if text is empty or non-numeric
          ELSE NULL 
        END;
      SQL
    end
  end
end
