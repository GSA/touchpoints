module Admin
  class CxCollectionDetailUploadsController < AdminController
    before_action :set_cx_collection_detail_upload

    def destroy
      ensure_service_manager_permissions

      @cx_collection_detail_upload.destroy

      respond_to do |format|
        Event.log_event(Event.names[:cx_collection_detail_upload_deleted], @cx_collection_detail_upload.class.to_s, @cx_collection_detail_upload.id, "CX Collection Detail Upload #{@cx_collection_detail_upload.id} deleted at #{DateTime.now}", current_user.id)
        format.html { redirect_to upload_admin_cx_collection_detail_path(@cx_collection_detail_upload.cx_collection_detail), notice: "CX Data Collection Upload was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    private
      def set_cx_collection_detail_upload
        @cx_collection_detail_upload = CxCollectionDetailUpload.find(params[:id])
      end

  end
end
