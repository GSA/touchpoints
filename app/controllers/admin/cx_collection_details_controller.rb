class Admin::CxCollectionDetailsController < AdminController
  before_action :set_cx_collection_detail, only: %i[
    show edit
    upload upload_csv process_csv
    update
    destroy
  ]
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
    @uploads = CxCollectionDetailUpload.where(cx_collection_detail_id: @cx_collection_detail.id)
  end

  def create
    @cx_collection_detail = CxCollectionDetail.new(cx_collection_detail_params)
    @cx_collection_detail.service_id = @cx_collection_detail.cx_collection.service_id

    respond_to do |format|
      if @cx_collection_detail.save
        format.html { redirect_to upload_admin_cx_collection_detail_url(@cx_collection_detail), notice: "CX Collection Detail was successfully created." }
        format.json { render :upload, status: :created, location: @cx_collection_detail }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @cx_collection_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @cx_collection_detail.update(cx_collection_detail_params)
        format.html { redirect_to admin_cx_collection_detail_url(@cx_collection_detail), notice: "CX Collection Detail was successfully updated." }
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
      format.html { redirect_to cx_collection_details_url, notice: "CX Collection Detail was successfully destroyed." }
      format.json { head :no_content }
    end
  end

    def export_csv
      @collections = CxCollectionDetail.all
      send_data @collections.to_csv, filename: "touchpoints-data-collection-details-#{Date.today}.csv"
    end

  # Handle a large-ish csv upload (5+ MB) to S3
  def upload_csv
    file = params[:file] # Assuming the file comes from a form field named 'file'

    file_extension = File.extname(file.original_filename).downcase

    @valid_file_extension = (file_extension == ".csv")

    # check the file to ensure it is valid
    csv_file = CSV.parse(file.read, headers: true)
    @valid_file_headers = csv_file.headers.sort == [
      "question_1",
      "positive_effectiveness",
      "positive_ease",
      "positive_efficiency",
      "positive_transparency",
      "positive_humanity",
      "positive_employee",
      "positive_other",
      "negative_effectiveness",
      "negative_ease",
      "negative_efficiency",
      "negative_transparency",
      "negative_humanity",
      "negative_employee",
      "negative_other",
      "question_4"
    ].sort

    if @valid_file_extension && @valid_file_headers
      bucket = ENV.fetch("S3_UPLOADS_AWS_BUCKET_NAME")
      key = "cx_data_collections/cx-upload-#{Time.now.to_i}-#{file.original_filename}"

      obj = s3_service.bucket(bucket).object(key)
      # Upload the file
      response = obj.upload_file(file.path)

      CxCollectionDetailUpload.create!({
        user_id: current_user.id,
        cx_collection_detail_id: @cx_collection_detail.id,
        size: obj.size,
        key: obj.key,
      })

      flash[:notice] = "A .csv file with #{csv_file.size} rows was uploaded successfully."
    elsif !@valid_file_extension
      flash[:notice] = "File has a file extension of #{file_extension}, but it should be .csv."
    elsif !@valid_file_headers
      flash[:notice] = "CSV headers do not match"
    end

    # render :upload
    redirect_to upload_admin_cx_collection_detail_path(@cx_collection_detail)
  end

  def process_csv
    job_id = SecureRandom.hex[0..5]
    uploaded_file = CxCollectionDetailUpload.find(params[:cx_collection_detail_upload_id])

    # Get the file from s3
    bucket = ENV.fetch("S3_UPLOADS_AWS_BUCKET_NAME")
    key = uploaded_file.key

    response = s3_service.client.get_object(bucket: bucket, key: key)
    string = response.body.read

    # Parse it
    csv = CSV.parse(string, headers: true)

    csv.each do |row|
      # Create the database record
      CxResponse.create!({
        cx_collection_detail_id: @cx_collection_detail.id,
        cx_collection_detail_upload_id: uploaded_file.id,
        job_id: job_id,
        question_1: row["question_1"],
        positive_effectiveness: row["positive_effectiveness"],
        positive_ease: row["positive_ease"],
        positive_efficiency: row["positive_efficiency"],
        positive_transparency: row["positive_transparency"],
        positive_humanity: row["positive_humanity"],
        positive_employee: row["positive_employee"],
        positive_other: row["positive_other"],
        negative_effectiveness: row["negative_effectiveness"],
        negative_ease: row["negative_ease"],
        negative_efficiency: row["negative_efficiency"],
        negative_transparency: row["negative_transparency"],
        negative_humanity: row["negative_humanity"],
        negative_employee: row["negative_employee"],
        negative_other: row["negative_other"],
        question_4: row["question_4"],
      })

    end

    flash[:notice] = "A .csv file with #{csv.size} rows was uploaded successfully."
    render :upload
  end

  private
    def set_cx_collection_detail
      @cx_collection_detail = CxCollectionDetail.find(params[:id])
    end

    def set_cx_collections
      if service_manager_permissions?
        @cx_collections = CxCollection.all.includes(:organization).order('organizations.abbreviation')
      else
        @cx_collections = current_user.organization.cx_collections
      end
    end

    def cx_collection_detail_params
      params.require(:cx_collection_detail).permit(:cx_collection_id, :service_id, :transaction_point, :channel, :service_stage_id, :volume_of_customers, :volume_of_customers_provided_survey_opportunity, :volume_of_respondents, :omb_control_number, :federal_register_url, :reflection_text, :survey_type, :survey_title, :trust_question_text)
    end
end
