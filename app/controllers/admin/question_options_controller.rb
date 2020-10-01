class Admin::QuestionOptionsController < AdminController
  before_action :set_question, only: [:new, :create, :show, :edit, :update, :destroy]
  before_action :set_question_option, only: [:show, :edit, :update, :destroy]

  def index
    @question_options = QuestionOption.all
  end

  def show
  end

  def new
    @question_option = QuestionOption.new
    render layout: false
  end

  def edit
    render layout: false
  end

  def update_title
    question_option = QuestionOption.where(id: params[:question_option_id]).first
    question_option.update!(text: params[:text])
    render json: question_option
  end

  def create
    @question_option = QuestionOption.new(question_option_params)
    @question_option.position = @question_option.question.question_options.size + 1

    respond_to do |format|
      if @question_option.save
        format.html { redirect_to questions_admin_form_path(@question.form), notice: 'Question option was successfully created.' }
        format.json { render :show, status: :created, location: @question_option }
      else
        format.html { render :new }
        format.json { render json: @question_option.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @question_option.update(question_option_params)
        format.html { redirect_to questions_admin_form_path(@question.form), notice: 'Question option was successfully updated.' }
        format.json { render :show, status: :ok, location: @question_option }
      else
        format.html { render :edit }
        format.json { render json: @question_option.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @question_option.destroy
    respond_to do |format|
      format.html { redirect_to questions_admin_form_path(@question_option.question.form), notice: 'Question option was successfully destroyed.' }
      format.js { }
    end
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
        :value
      )
    end
end
