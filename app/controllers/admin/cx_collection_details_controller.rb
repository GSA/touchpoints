class Admin::CxCollectionDetailsController < AdminController
  before_action :set_cx_collection_detail, only: %i[ show edit upload upload_csv update destroy ]
  before_action :set_cx_collections, only: %i[ new edit upload ]

  def index
    @cx_collection_details = CxCollectionDetail.all
  end

  def show
  end

  def new
    @cx_collection_detail = CxCollectionDetail.new
    @cx_collection_detail.cx_collection_id = params[:collection_id]
  end

  def edit
  end

  def upload
  end

  def create
    @cx_collection_detail = CxCollectionDetail.new(cx_collection_detail_params)
    @cx_collection_detail.service_id = @cx_collection_detail.cx_collection.service_id

    respond_to do |format|
      if @cx_collection_detail.save
        format.html { redirect_to admin_cx_collection_detail_url(@cx_collection_detail), notice: "Cx collection detail was successfully created." }
        format.json { render :show, status: :created, location: @cx_collection_detail }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @cx_collection_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @cx_collection_detail.update(cx_collection_detail_params)
        format.html { redirect_to admin_cx_collection_detail_url(@cx_collection_detail), notice: "Cx collection detail was successfully updated." }
        format.json { render :show, status: :ok, location: @cx_collection_detail }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @cx_collection_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @cx_collection_detail.destroy

    respond_to do |format|
      format.html { redirect_to cx_collection_details_url, notice: "Cx collection detail was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # Handle a large-ish csv upload (5+ MB) to S3
  def upload_csv
    file = params[:file] # Assuming the file comes from a form field named 'file'
    bucket = ENV.fetch("S3_UPLOADS_AWS_BUCKET_NAME")

    s3 = Aws::S3::Resource.new
    key = "cx_data_collections/cx-upload-#{Time.now.to_i}-#{file.original_filename}}"
    obj = s3.bucket(bucket).object(file.original_filename)
    # Upload the file
    response = obj.upload_file(file.path)

    CxCollectionDetailUpload.create!({
      user_id: current_user.id,
      cx_collection_detail_id: @cx_collection_detail.id,
      size: obj.size,
      key: obj.key,
    })

    render :upload, message: 'File successfully uploaded'
  end

  private
    def set_cx_collection_detail
      @cx_collection_detail = CxCollectionDetail.find(params[:id])
    end

    def set_cx_collections
      if service_manager_permissions?
        @cx_collections = CxCollection.all.includes(:organization)
      else
        @cx_collections = current_user.organization.cx_collections
      end
    end

    def cx_collection_detail_params
      params.require(:cx_collection_detail).permit(:cx_collection_id, :service_id, :transaction_point, :channel, :service_stage_id, :volume_of_customers, :volume_of_customers_provided_survey_opportunity, :volume_of_respondents, :omb_control_number, :federal_register_url, :reflection_text, :survey_type, :survey_title, :trust_question_text)
    end
end
