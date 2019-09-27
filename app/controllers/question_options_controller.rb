class QuestionOptionsController < ApplicationController
  before_action :ensure_admin
  before_action :set_question_option, only: [:show, :edit, :update, :destroy]

  def index
    @question_options = QuestionOption.all
  end

  def show
  end

  def new
    @question_option = QuestionOption.new
  end

  def edit
  end

  def create
    @question_option = QuestionOption.new(question_option_params)

    respond_to do |format|
      if @question_option.save
        format.html { redirect_to @question_option, notice: 'Question option was successfully created.' }
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
        format.html { redirect_to @question_option, notice: 'Question option was successfully updated.' }
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
      format.html { redirect_to question_options_url, notice: 'Question option was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question_option
      @question_option = QuestionOption.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_option_params
      params.require(:question_option).permit(:question_id, :text, :position)
    end
end
