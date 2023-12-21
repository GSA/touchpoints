class CxResponse < ApplicationRecord
  belongs_to :cx_collection_detail
  belongs_to :cx_collection_detail_upload
end
