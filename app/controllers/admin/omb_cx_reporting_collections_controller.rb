# frozen_string_literal: true

module Admin
  class OmbCxReportingCollectionsController < AdminController
    before_action :set_omb_cx_reporting_collection, only: %i[show edit update destroy]
    before_action :set_collections, only: %i[new create edit update]

    def index
      ensure_admin
      @omb_cx_reporting_collections = OmbCxReportingCollection.all
    end

    def show; end

    def new
      @omb_cx_reporting_collection = OmbCxReportingCollection.new

      @omb_cx_reporting_collection.collection_id = params[:collection_id] if params[:collection_id] && @collection = Collection.find(params[:collection_id])
    end

    def edit; end

    def create
      @omb_cx_reporting_collection = OmbCxReportingCollection.new(omb_cx_reporting_collection_params)

      if @omb_cx_reporting_collection.save
        redirect_to admin_omb_cx_reporting_collection_path(@omb_cx_reporting_collection), notice: 'Omb cx reporting collection was successfully created.'
      else
        render :new
      end
    end

    def update
      if @omb_cx_reporting_collection.update(omb_cx_reporting_collection_params)
        redirect_to admin_omb_cx_reporting_collection_path(@omb_cx_reporting_collection), notice: 'Omb cx reporting collection was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @omb_cx_reporting_collection.destroy
      redirect_to admin_collection_url(@omb_cx_reporting_collection.collection), notice: 'Omb cx reporting collection was successfully destroyed.'
    end

    private

    def set_omb_cx_reporting_collection
      @omb_cx_reporting_collection = OmbCxReportingCollection.find(params[:id])
    end

    def set_collections
      if admin_permissions?
        @collections = Collection.all
      else
        @collections = current_user.collections
      end
    end

    def omb_cx_reporting_collection_params
      params.require(:omb_cx_reporting_collection).permit(
        :collection_id,
        :service_id,
        :service_provided,
        :transaction_point,
        :channel,
        :volume_of_customers,
        :volume_of_customers_provided_survey_opportunity,
        :volume_of_respondents,
        :omb_control_number,
        :federal_register_url,
        :operational_metrics,
        :q1_text,
        :q1_1,
        :q1_2,
        :q1_3,
        :q1_4,
        :q1_5,
        :q2_text,
        :q2_1,
        :q2_2,
        :q2_3,
        :q2_4,
        :q2_5,
        :q3_text,
        :q3_1,
        :q3_2,
        :q3_3,
        :q3_4,
        :q3_5,
        :q4_text,
        :q4_1,
        :q4_2,
        :q4_3,
        :q4_4,
        :q4_5,
        :q5_text,
        :q5_1,
        :q5_2,
        :q5_3,
        :q5_4,
        :q5_5,
        :q6_text,
        :q6_1,
        :q6_2,
        :q6_3,
        :q6_4,
        :q6_5,
        :q7_text,
        :q7_1,
        :q7_2,
        :q7_3,
        :q7_4,
        :q7_5,
        :q8_text,
        :q8_1,
        :q8_2,
        :q8_3,
        :q8_4,
        :q8_5,
        :q9_text,
        :q9_1,
        :q9_2,
        :q9_3,
        :q9_4,
        :q9_5,
        :q10_text,
        :q10_1,
        :q10_2,
        :q10_3,
        :q10_4,
        :q10_5,
        :q11_text,
        :q11_1,
        :q11_2,
        :q11_3,
        :q11_4,
        :q11_5,
      )
    end
  end
end
