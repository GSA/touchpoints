# frozen_string_literal: true

module Admin
  class QuestionsController < AdminController
    before_action :set_form, only: %i[create edit update sort destroy]
    before_action :ensure_form_manager_access, only: %i[create edit update sort destroy]
    before_action :set_question, only: %i[edit update destroy]

    def edit
      render layout: false
    end

    def sort
      form_section = @form.form_sections.find(params[:form_section_id])
      question_ids = Array(params[:question]).map(&:to_s)
      current_question_ids = form_section.questions.ids.map(&:to_s)

      unless question_ids.sort == current_question_ids.sort
        render json: { error: 'All questions in the section must be listed exactly once' }, status: :unprocessable_content
        return
      end

      Question.transaction do
        question_ids.each_with_index do |id, index|
          form_section.questions.find(id).update!(position: index + 1)
        end
      end

      head :ok
    end

    def create
      @question = @form.questions.new
      set_defaults

      respond_to do |format|
        if @question.save
          format.html { render :new, layout: false }
          format.json { render json: @question }
        else
          format.html { render :new }
          format.json { render json: @question.errors, status: :unprocessable_content }
        end
      end
    end

    def update
      attributes = question_params
      if attributes[:form_section_id].present?
        attributes[:form_section_id] = @form.form_sections.find(attributes[:form_section_id]).id
      end

      respond_to do |format|
        format.html { render layout: false }
        if @question.update(attributes)
          format.json { render json: @question }
        else
          format.json { render json: @question.errors, status: :unprocessable_content }
        end
      end
    end

    def destroy
      @question.destroy
      respond_to do |format|
        format.js {}
        format.html { redirect_to questions_admin_form_url(@form), notice: 'Question was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private

    def set_form
      @form = Form.find_by_short_uuid(params[:form_id])
    end

    def set_question
      @question = @form.questions.find(params[:id])
    end

    def ensure_form_manager_access
      ensure_form_manager(form: @form)
    end

    def set_defaults
      @question.form_section = @form.form_sections.find(params[:form_section_id])
      @question.text = 'New Question'
      @question.question_type = 'text_field'
      @question.answer_field = first_unused_answer_field
      next_position = @form.questions.size + 1
      @question.position = next_position
    end

    def question_params
      params.require(:question).permit(
        :form_section_id,
        :question_type,
        :text,
        :placeholder_text,
        :help_text,
        :answer_field,
        :position,
        :is_required,
        :character_limit,
      )
    end

    def first_unused_answer_field
      answer_fields = @form.questions.collect(&:answer_field)
      (1..30).each do |ind|
        af = "answer_#{ind.to_s.rjust(2, '0')}"
        return af unless answer_fields.include?(af)
      end
      'answer_01'
    end
  end
end
