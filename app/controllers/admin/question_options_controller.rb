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
      text_array = question_option_params[:text].split("\n")
      position = @question.question_options.size + 1
      @new_question_options = []
      @errors = []
      result = false

      if text_array.length.positive? # multiple options
        text_array.each do |txt|
          if ["radio_buttons", "checkbox"].include?(@question.question_type)
            if txt.upcase == 'OTHER' || txt.upcase == 'OTRO'
              @errors << "Use add #{txt} button"
              next
            end
          end
          @question_option = QuestionOption.where(question_id: params[:question_id], text: txt).first
          if @question_option
            @errors << "Question option already exists for text #{txt}"
            next
          end
          @question_option = QuestionOption.new(question_id: params[:question_id], text: txt, value: txt, position:)
          if @question_option.save
            @new_question_options << @question_option
            position += 1
          else
            @errors << @question_option.errors.full_messages
          end
        end
      else
        @question_option = QuestionOption.where(question_id: params[:question_id], text: params[:text]).first
        if question_option
          @errors << "Question option already exists for text #{params[:text]}"
        else
          @question_option = QuestionOption.new(question_option_params)
          @question_option.position = position
          if @question_option.save
            @new_question_options << @question_option
            # ok
          else
            @errors << @question_option.errors.full_messages
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
