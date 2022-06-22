# frozen_string_literal: true

module Admin
  class QuestionsController < AdminController
    before_action :set_form, only: %i[new create show edit update sort destroy]
    before_action :set_question, only: %i[show edit update destroy]

    def index
      @questions = Question.all.order(:position)
    end

    def show
      render layout: false
    end

    def new
      @question = Question.new
      set_defaults
      render layout: false
    end

    def edit
      render layout: false
    end

    def sort
      form_section_id = params[:form_section_id]
      params[:question].each_with_index do |id, index|
        @form.questions.find(id).update(position: index + 1, form_section_id:)
      end

      head :ok
    end

    def create
      next_position = @form.questions.size + 1
      @question = Question.new(question_params)
      @question.position = next_position

      respond_to do |format|
        if @question.save
          format.html { redirect_to questions_admin_form_path(@form), notice: 'Question was successfully created.' }
          format.json { render json: @question }
        else
          format.html { render :new }
          format.json { render json: @question.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        format.html { render layout: false }
        if @question.update(question_params)
          format.json { render json: @question }
        else
          format.json { render json: @question.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      ensure_form_manager(form: @form)

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

    def set_defaults
      @question.form_id = @form.id
      @question.form_section_id = params[:form_section_id]
      @question.text = 'New Question'
      @question.question_type = 'text_field'
      @question.answer_field = first_unused_answer_field
      @question.save!
    end

    def question_params
      params.require(:question).permit(
        :form_id,
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
      answer_fields = Question.where(form_id: @form.id).collect(&:answer_field)
      (1..20).each do |ind|
        af = "answer_#{ind.to_s.rjust(2, '0')}"
        return af unless answer_fields.include?(af)
      end
      'answer_01'
    end
  end
end
