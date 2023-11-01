class CxCollectionDetail < ApplicationRecord
    belongs_to :cx_collection
    belongs_to :service
    belongs_to :service_stage, optional: true
end
