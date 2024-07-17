class CxCollectionDetailUpload < ApplicationRecord
  include AASM
  include S3Helper

  belongs_to :user
  belongs_to :cx_collection_detail

  after_create :process_csv_in_a_worker

  aasm do
    state :created, initial: true
    state :processing
    state :processed

    event :process do
      transitions from: [:created], to: :processing
    end
    event :complete do
      transitions from: [:processing], to: :processed
    end
    event :reset do
      transitions to: :created
    end
  end

  def process_csv_in_a_worker
    process_csv
  end

  def process_csv
    return if Rails.env.test?

    job_id = SecureRandom.hex[0..9]
    update_attribute(:job_id, job_id)
    uploaded_file = self

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
        external_id: row["external_id"],
        cx_collection_detail_id: cx_collection_detail.id,
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
  end

end
