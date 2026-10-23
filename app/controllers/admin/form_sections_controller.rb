# frozen_string_literal: true

module Admin
  class FormSectionsController < AdminController
    before_action :set_form, only: %i[new create edit update destroy sort update_title]
    before_action :ensure_form_manager_access, only: %i[new create edit update destroy sort update_title]
    before_action :set_form_section, only: %i[edit update destroy sort update_title]

    def new
      @section = @form.form_sections.new
      @section.title = 'New Section'
      @section.position = next_section_position
      @section.save!
      @tabindex = 0
      @multi_section_question_number = 0
      render layout: false
    end

    def edit
      render layout: false
    end

    def sort
      section_ids = Array(params[:form_section]).map(&:to_s)
      current_section_ids = @form.form_sections.ids.map(&:to_s)

      unless section_ids.sort == current_section_ids.sort
        render json: { error: 'All form sections must be listed exactly once in reordering request' }, status: :unprocessable_content
        return
      end

      FormSection.transaction do
        section_ids.each_with_index do |id, index|
          @form.form_sections.where(id:).update_all(position: index + 1)
        end
        # update_all skips callbacks. Touch the form so invalidation happens
        # after the complete reorder commits, not partway through it.
        @form.touch
      end

      head :ok
    end

    def update_title
      @form_section.update!(title: params[:title])
      render json: @form_section
    end

    def create
      @form_section = @form.form_sections.new(form_section_params)
      @form_section.position = next_section_position

      if @form_section.save
        redirect_to questions_admin_form_path(@form), notice: 'Form section was successfully created.'
      else
        render :new
      end
    end

    def update
      if @form_section.update(form_section_params)
        redirect_to questions_admin_form_url(@form), notice: 'Form section was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      if @form.form_sections.count < 1
        redirect_to questions_admin_form_url(@form), alert: 'Cannot delete only remaining Form section'
      elsif @form_section.destroy
        redirect_to questions_admin_form_url(@form), notice: 'Form section was successfully deleted.'
      else
        redirect_to questions_admin_form_url(@form), alert: 'Form section cannot be deleted because it has one or more questions.'
      end
    end

    private

    def set_form_section
      @form_section = @form.form_sections.find(params[:id])
    end

    def set_form
      @form = Form.find_by_short_uuid(params[:form_id])
    end

    def ensure_form_manager_access
      ensure_form_manager(form: @form)
    end

    def form_section_params
      params.require(:form_section).permit(:title, :position)
    end

    def next_section_position
      (@form.form_sections.maximum(:position) || 0) + 1
    end
  end
end
