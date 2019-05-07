class Admin::PraContactsController < AdminController
  before_action :ensure_admin
  before_action :set_pra_contact, only: [:show, :edit, :update, :destroy]

  # GET /pra_contacts
  # GET /pra_contacts.json
  def index
    @pra_contacts = PraContact.all
  end

  # GET /pra_contacts/1
  # GET /pra_contacts/1.json
  def show
  end

  # GET /pra_contacts/new
  def new
    @pra_contact = PraContact.new
  end

  # GET /pra_contacts/1/edit
  def edit
  end

  # POST /pra_contacts
  # POST /pra_contacts.json
  def create
    @pra_contact = PraContact.new(pra_contact_params)

    respond_to do |format|
      if @pra_contact.save
        format.html { redirect_to admin_pra_contact_path(@pra_contact), notice: 'Pra contact was successfully created.' }
        format.json { render :show, status: :created, location: @pra_contact }
      else
        format.html { render :new }
        format.json { render json: @pra_contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pra_contacts/1
  # PATCH/PUT /pra_contacts/1.json
  def update
    respond_to do |format|
      if @pra_contact.update(pra_contact_params)
        format.html { redirect_to admin_pra_contact_path(@pra_contact), notice: 'Pra contact was successfully updated.' }
        format.json { render :show, status: :ok, location: @pra_contact }
      else
        format.html { render :edit }
        format.json { render json: @pra_contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pra_contacts/1
  # DELETE /pra_contacts/1.json
  def destroy
    @pra_contact.destroy
    respond_to do |format|
      format.html { redirect_to admin_pra_contacts_url, notice: 'Pra contact was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pra_contact
      @pra_contact = PraContact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pra_contact_params
      params.require(:pra_contact).permit(:email, :name, :department, :program, :organization_id, :program_id)
    end
end
