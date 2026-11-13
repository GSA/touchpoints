# frozen_string_literal: true

module Admin
  class QuestionOptionsController < AdminController
    before_action :set_form, only: %i[new create create_other edit update destroy sort update_title]
    before_action :ensure_form_manager_access, only: %i[new create create_other edit update destroy sort update_title]
    before_action :set_question, only: %i[new create create_other edit update destroy sort update_title]
    before_action :set_question_option, only: %i[edit update destroy update_title]

    def new
      @question_option = @question.question_options.new
      render layout: false
    end

    def edit
      render layout: false
    end

    def sort
      option_ids = Array(params[:question_option]).map(&:to_s)
      current_option_ids = @question.question_options.pluck(:id).map(&:to_s)
      unless current_option_ids.sort == option_ids.sort
        render json: { error: "All question options must be listed exactly once in reordering request" }, status: :unprocessable_content
        return
      end

      QuestionOption.transaction do
        option_ids.each_with_index do |id, index|
          @question.question_options.find(id).update!(position: index + 1)
        end
      end
      head :ok
    end

    def update_title
      @question_option.update!(text: params[:text])
      render json: @question_option
    end

    def create
      attributes = question_option_params
      texts = attributes[:text].to_s.split(/\r\n|\r|\n/).reject(&:blank?)
      @new_question_options = []
      @errors = []

      if texts.empty?
        @errors << "Text can't be blank"
      elsif texts.many? && attributes[:value].present?
        @errors << 'Value must be empty when creating multiple options'
      else
        position = @question.question_options.size + 1
        texts.each do |text|
          if ["radio_buttons", "checkbox"].include?(@question.question_type) && ['OTHER', 'OTRO'].include?(text.upcase)
            @errors << "Use add #{text} button"
            next
          end
          if @question.question_options.exists?(text:)
            @errors << "Question option already exists for text #{text}"
            next
          end

          value = attributes[:value] if texts.one?
          @question_option = @question.question_options.new(text:, value:, position:)
          if @question_option.save
            @new_question_options << @question_option
            position += 1
          else
            @errors.concat(@question_option.errors.full_messages)
          end
        end
      end

      render :create, format: :js
    end

    def create_other
      @new_question_options = []
      @errors = []

      if @question.question_options.detect { |option| option.other_option }
        @errors << "An Other option already exists"
      else
        @question_option = @question.question_options.new(other_option: true)
        @question_option.position = @question.question_options.size + 1
        @question_option.text = 'Other'
        @question_option.value = 'OTHER'
        @question_option.save!
        @new_question_options << @question_option
      end

      render :create, format: :js
    end

    def update
      @question_option.update(question_option_params)
      render :update, format: :js
    end

    def destroy
      @question_option.destroy
      head :ok
    end

    private

    def set_form
      @form = Form.find_by!(short_uuid: params[:form_id])
    end

    def ensure_form_manager_access
      ensure_form_manager(form: @form)
    end

    def set_question_option
      @question_option = @question.question_options.find(params[:id])
    end

    def set_question
      @question = @form.questions.find(params[:question_id])
    end

    def question_option_params
      params.require(:question_option).permit(
        :text,
        :position,
        :value,
      )
    end
  end
end
