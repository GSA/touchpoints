class Admin::ReportingController < AdminController
  def hisps
    row = []
    header_fields = [
        :department,
        :department_abbreviation,
        :service_provider_id,
        :name,
        :description,
        :notes,
        :new_hisp
      ]

    row << header_fields.join(",")

    ServiceProvider.active.includes(:organization).order("organizations.name", :name).each do |hisp|
    row_fields = [
        hisp.organization.name,
        hisp.organization.abbreviation.downcase,
        hisp.slug,
        "\"#{hisp.name}\"",
        "\"#{hisp.description}\"",
        "\"#{hisp.notes}\"",
        hisp.new,
      ]
      row << row_fields.join(",")
    end

    render plain: row.join("\n")
  end

  def hisp_services
    row = []
    header_fields = [
      :organization_name,
      :organization_abbreviation,
      :organization_id,
      :service_provider_name,
      :service_provider_slug,
      :year,
      :quarter,
      :service_provided,
      :transaction_point,
      :channel,
      :total_volume,
      :surveys_offered_count,
      :response_count,
      :satisfied,
      :trust,
      :effective,
      :easy,
      :efficient,
      :transparent,
      :employee
    ]

    row << header_fields.join(",")

    ServiceProvider.all.includes(:organization).order("organizations.name", :name).each do |service_provider|
      service_provider.services.order(:name).each do |service|
        service.omb_cx_reporting_collections.includes(:service, :collection).order("collections.year", "collections.quarter", "services.name").each do |omb_cx_reporting_collection|

          row_fields = [
            omb_cx_reporting_collection.organization_abbreviation,
            "\"#{omb_cx_reporting_collection.organization_name}\"",
            omb_cx_reporting_collection.organization_id,
            "\"#{omb_cx_reporting_collection.collection.service_provider.name}\"",
            omb_cx_reporting_collection.collection.service_provider.slug,
            omb_cx_reporting_collection.collection.year,
            omb_cx_reporting_collection.collection.quarter,
            "\"#{omb_cx_reporting_collection.service_provided}\"",
            "\"#{omb_cx_reporting_collection.transaction_point}\"",
            "\"#{omb_cx_reporting_collection.channel}\"",
            omb_cx_reporting_collection.volume_of_customers,
            omb_cx_reporting_collection.volume_of_customers_provided_survey_opportunity,
            omb_cx_reporting_collection.volume_of_respondents,
            omb_cx_reporting_collection.q1_point_scale,
            omb_cx_reporting_collection.q2_point_scale,
            omb_cx_reporting_collection.q3_point_scale,
            omb_cx_reporting_collection.q4_point_scale,
            omb_cx_reporting_collection.q5_point_scale,
            omb_cx_reporting_collection.q6_point_scale,
            omb_cx_reporting_collection.q7_point_scale
          ]
          row << row_fields.join(",")

        end
      end
    end

    render plain: row.join("\n")
  end

  def hisp_service_cx_data_collections
    rows = []
    header_fields = [
      :organization_abbreviation,
      :organization_name,
      :organization_id,
      :service_provider_name,
      :service_provider_id,
      :service_id,
      :year,
      :quarter,
      :service_provided,
      :transaction_point,
      :channel,
      :standardized_question_number,
      :standardized_question_identifier,
      :customized_question_text,
      :likert_scale_1,
      :likert_scale_2,
      :likert_scale_3,
      :likert_scale_4,
      :likert_scale_5,
      :point_scale,
      :response_volume,
      :notes,
      :question_total,
      :start_date,
      :end_date
    ]

    rows << header_fields.join(",")

    ServiceProvider.active.includes(:organization).order("organizations.name", :name).each do |service_provider|
      service_provider.services.includes(:organization).order("organizations.name", :name).each do |service|
        if params[:quarter]
          @collections = service.collections.where(quarter: params[:quarter])
        else
          @collections = service.collections
        end

        @collections.each do |collection|
          collection.omb_cx_reporting_collections.includes(:collection).order("collections.year", "collections.quarter", "omb_cx_reporting_collections.service_provided", "omb_cx_reporting_collections.channel").each do |omb_cx_reporting_collection|
            # WRITE A CSV LINE FOR EACH OF THE 7 STANDARD QUESTIONS
            (1..7).each do |question_number|
              next if params[:question] && (question_number.to_s != params[:question])

              row_fields = [
                omb_cx_reporting_collection.organization_abbreviation,
                "\"#{omb_cx_reporting_collection.organization_name}\"",
                omb_cx_reporting_collection.organization_id,
                "\"#{omb_cx_reporting_collection.collection.service_provider.name}\"",
                omb_cx_reporting_collection.collection.service_provider.slug,
                omb_cx_reporting_collection.service.service_slug,
                omb_cx_reporting_collection.collection.year,
                omb_cx_reporting_collection.collection.quarter,
                "\"#{omb_cx_reporting_collection.service_provided}\"",
                "\"#{omb_cx_reporting_collection.transaction_point}\"",
                "\"#{omb_cx_reporting_collection.channel}\"",
                question_number,
                hisp_questions_key[question_number.to_s],
                "\"#{omb_cx_reporting_collection.send("q#{question_number}_text")}\"",
                omb_cx_reporting_collection.send("q#{question_number}_1"),
                omb_cx_reporting_collection.send("q#{question_number}_2"),
                omb_cx_reporting_collection.send("q#{question_number}_3"),
                omb_cx_reporting_collection.send("q#{question_number}_4"),
                omb_cx_reporting_collection.send("q#{question_number}_5"),
                omb_cx_reporting_collection.send("q#{question_number}_point_scale"),
                omb_cx_reporting_collection.question_total(question: "q#{question_number}"),
                "",
                omb_cx_reporting_collection.collection.start_date,
                omb_cx_reporting_collection.collection.end_date
              ]
              rows << row_fields.join(",")

            end
          end
        end
      end
    end

    render plain: rows.join("\n")
  end

  def hisp_service_question_details
    rows = []
    header_fields = [
      :organization_abbreviation,
      :organization_name,
      :organization_id,
      :service_provider_name,
      :service_provider_id,
      :service_name,
      :service_id,
      :year,
      :quarter,
      :service_provided,
      :transaction_point,
      :channel,
      :standardized_question_number,
      :standardized_question_identifier,
      :customized_question_text,
      :likert_scale_1,
      :likert_scale_2,
      :likert_scale_3,
      :likert_scale_4,
      :likert_scale_5,
      :point_scale,
      :response_volume,
      :notes,
      :question_total,
      :start_date,
      :end_date
    ]

    header_fields.join(",")

    rows << header_fields.join(",")

    ServiceProvider.active.includes(:organization).order("organizations.name", :name).each do |service_provider|
      service_provider.services.includes(:organization).order("organizations.name", :name).each do |service|
        if params[:quarter]
          @collections = service.collections.where(quarter: params[:quarter])
        else
          @collections = service.collections
        end

        @collections.each do |collection|
          collection.omb_cx_reporting_collections.includes(:collection).order("collections.year", "collections.quarter", "omb_cx_reporting_collections.service_provided", "omb_cx_reporting_collections.channel").each do |omb_cx_reporting_collection|
             # WRITE A CSV LINE FOR EACH OF THE 7 STANDARD QUESTIONS
            (1..7).each do |question_number|
              next if params[:question] && (question_number.to_s != params[:question])

              row_fields = [
                omb_cx_reporting_collection.organization_abbreviation,
                "\"#{omb_cx_reporting_collection.organization_name}\"",
                omb_cx_reporting_collection.organization_id,
                "\"#{omb_cx_reporting_collection.collection.service_provider.name}\"",
                omb_cx_reporting_collection.collection.service_provider.slug,
                omb_cx_reporting_collection.service.name,
                omb_cx_reporting_collection.service.service_slug,
                omb_cx_reporting_collection.collection.year,
                omb_cx_reporting_collection.collection.quarter,
                "\"#{omb_cx_reporting_collection.service_provided}\"",
                omb_cx_reporting_collection.transaction_point,
                omb_cx_reporting_collection.channel,
                question_number,
                hisp_questions_key[question_number.to_s],
                "\"#{omb_cx_reporting_collection.send("q#{question_number}_text")}\"",
                omb_cx_reporting_collection.send("q#{question_number}_1"),
                omb_cx_reporting_collection.send("q#{question_number}_2"),
                omb_cx_reporting_collection.send("q#{question_number}_3"),
                omb_cx_reporting_collection.send("q#{question_number}_4"),
                omb_cx_reporting_collection.send("q#{question_number}_5"),
                omb_cx_reporting_collection.send("q#{question_number}_point_scale"),
                omb_cx_reporting_collection.question_total(question: "q#{question_number}"),
                omb_cx_reporting_collection.collection.start_date,
                omb_cx_reporting_collection.collection.end_date,
              ]

               rows << row_fields.join(",")
            end # 1..7
          end # omb_cx_reporting_collection
        end # collection
      end # service
    end # service_provider

    render plain: rows.join("\n")
  end

  def lifespan
    @form_lifespans = Submission.select("form_id, count(*) as num_submissions, (max(submissions.created_at) - min(submissions.created_at)) as lifespan").group(:form_id)
    @forms = Form.select(:id,:name,:organization_id,:uuid).where("exists (select id, uuid from submissions where submissions.form_id = forms.id)")
    @orgs = Organization.all.order(:name)
    @org_summary = []
    @orgs.each do | org |
      org_row = {}
      org_row[:name] = org.name
      org_row[:forms] = []
      total_lifespan = 0
      total_submissions = 0
      @forms.select { |form| form.organization_id == org.id }.each do |org_form|
        form_summary = {}
        form_summary[:id] = org_form.id
        form_summary[:name] = org_form.name
        form_summary[:short_uuid] = org_form.short_uuid
        form_summary[:counts] = @form_lifespans.select { |row| row.form_id == org_form.id }.first
        total_lifespan += form_summary[:counts].lifespan if form_summary[:counts].present?
        total_submissions += form_summary[:counts].num_submissions if form_summary[:counts].present?
        org_row[:forms] << form_summary
      end
      org_row[:submissions] = total_submissions
      org_row[:avg_lifespan] = org_row[:forms].size > 0 ? (total_lifespan / org_row[:forms].size) : 0
      @org_summary << org_row
    end
  end

  def no_submissions
    @forms = Form.live.select(:id,:name,:organization_id,:uuid).where("not exists (select id, uuid from submissions where submissions.form_id = forms.id and submissions.created_at > current_date - interval '30' day)").order(:organization_id)
    @orgs = Organization.all.order(:name)
    @org_summary = []
    @orgs.each do | org |
      org_row = {}
      org_row[:name] = org.name
      org_row[:forms] = []
      @forms.select { |form| form.organization_id == org.id }.each do |org_form|
        form_summary = {}
        form_summary[:id] = org_form.id
        form_summary[:name] = org_form.name
        form_summary[:short_uuid] = org_form.short_uuid
        org_row[:forms] << form_summary
      end
      @org_summary << org_row
    end
  end
end
