class RemoveCustomA11Fields < ActiveRecord::Migration[5.2]
  def change
    remove_column :submissions, :first_name
    remove_column :submissions, :last_name
    remove_column :submissions, :phone_number
    remove_column :submissions, :email
    remove_column :submissions, :body
    remove_column :submissions, :overall_satisfaction
    remove_column :submissions, :service_confidence
    remove_column :submissions, :service_effectiveness
    remove_column :submissions, :process_ease
    remove_column :submissions, :process_efficiency
    remove_column :submissions, :process_transparency
    remove_column :submissions, :people_employees
  end
end
