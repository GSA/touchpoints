# frozen_string_literal: true

module Admin
  class QuestionOptionsController < AdminController
    before_action :set_question, only: %i[new create create_other show edit update destroy]
    before_action :set_question_option, only: %i[show edit update destroy]

    def index
      @question_options = QuestionOption.all
    end

    def show; end

    def new
      @question_option = QuestionOption.new
      render layout: false
    end

    def edit
      render layout: false
    end

    def sort
      params[:question_option].each_with_index do |id, index|
        QuestionOption.find(id).update(position: index + 1)
      end

      head :ok
    end

    def update_title
      question_option = QuestionOption.where(id: params[:question_option_id]).first
      question_option.update!(text: params[:text])
      render json: question_option
    end

    def create
      text_array = question_option_params[:text].split("\n")
      position = @question.question_options.size + 1
      @question_options = []
      @errors = []
      result = false

      if text_array.length.positive?
        text_array.each do |txt|
          if txt.upcase == 'OTHER' || txt.upcase == 'OTRO'
            @errors << "Use add #{txt} button"
            next
          end
          question_option = QuestionOption.where(question_id: params[:question_id], text: txt).first
          if question_option
            @errors << "Question option already exists for text #{txt}"
            next
          end
          question_option = QuestionOption.new(question_id: params[:question_id], text: txt, value: txt, position:)
          if question_option.save
            @question_options << question_option
            position += 1
          else
            @errors << question_option.errors.full_messages
          end
        end
      else
        question_option = QuestionOption.where(question_id: params[:question_id], text: params[:text]).first
        if question_option
          @errors << "Question option already exists for text #{params[:text]}"
        else
          question_option = QuestionOption.new(question_option_params)
          question_option.position = position
          if question_option.save
            @question_options << question_option
          else
            @errors << question_option.errors.full_messages
          end
        end
      end
      render :create, format: :js
    end

    def create_other
      @errors = []
      question_option = QuestionOption.new
      question_option.position = @question.question_options.size + 1
      question_option.question_id = @question.id
      question_option.text = 'Other'
      question_option.value = 'OTHER'
      question_option.save!
      @question_options = [question_option]
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

    def set_question_option
      @question_option = QuestionOption.find(params[:id])
    end

    def set_question
      @question = Question.find(params[:question_id])
    end

    def question_option_params
      params.require(:question_option).permit(
        :question_id,
        :text,
        :position,
        :value,
      )
    end
  end
end
