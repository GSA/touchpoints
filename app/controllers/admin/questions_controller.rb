class Admin::QuestionsController < AdminController
  before_action :set_form, only: [:new, :create, :show, :edit, :update, :destroy]
  before_action :all_questions, only: [:index, :create, :update]
  before_action :set_question, only: [:show, :edit, :update, :destroy]

  def show
  end

  def new
    @question = Question.new
    render layout: false
  end

  def edit
    render layout: false
  end

  def create
    @question = Question.new(question_params)

    respond_to do |format|
      if @question.save
        format.html { redirect_to edit_admin_form_path(@form), notice: 'Question was successfully created.' }
        format.js { render :layout => false }
        format.json { render :index, status: :created, location: @question }
      else
        format.html { render :new }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @question.update(question_params)
        format.html { redirect_to edit_admin_form_question_path(@form,question), notice: 'Question was successfully updated.' }
        format.js { render :layout => false }
        format.json {
          render :show, status: :ok, location: @question
        }
      else
        format.html { render :edit }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    ensure_form_manager(form: @form)

    @question.destroy
    respond_to do |format|
      format.html { redirect_to edit_admin_form_url, notice: 'Question was successfully destroyed.' }
      format.js { render :layout => false }
      format.json { head :no_content }
    end
  end

  private
    def all_questions
      @questions = Question.all
    end  

    def set_question
      @question = Question.find(params[:id])
    end

    def set_form
      @form = Form.find_by_short_uuid(params[:form_id])
    end

    def question_params
      params.require(:question).permit(
        :form_id,
        :form_section_id,
        :text,
        :question_type,
        :answer_field,
        :position,
        :is_required,
        :character_limit
      )
    end
end
