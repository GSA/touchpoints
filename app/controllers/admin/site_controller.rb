# frozen_string_literal: true

module Admin
  class SiteController < AdminController
    def index
      @forms = Form.non_templates
      @agencies = Organization.order(:name)

      @days_since = params[:recent] && params[:recent].to_i <= 365 ? params[:recent].to_i : 3
      @dates = (@days_since.days.ago.to_date..Date.today).map { |date| date }

      @response_groups = Submission.group('date(created_at)').count.sort.last(@days_since.days)
      @user_groups = User.group('date(created_at)').count.sort.last(@days_since.days)
      @inactive_user_groups = User.where(inactive: true).group('date(updated_at)').count.sort.last(@days_since.days)
      todays_submissions = Submission.where('created_at > ?', Time.zone.now - @days_since.days)

      # Add in 0 count days to fetched analytics
      @dates.each do |date|
        @user_groups << [date, 0] unless @user_groups.detect { |row| row[0].strftime('%m %d %Y') == date.strftime('%m %d %Y') }
        @inactive_user_groups << [date, 0] unless @inactive_user_groups.detect { |row| row[0].strftime('%m %d %Y') == date.strftime('%m %d %Y') }
        @response_groups << [date, 0] unless @response_groups.detect { |row| row[0].strftime('%m %d %Y') == date.strftime('%m %d %Y') }
      end
      @user_groups = @user_groups.sort
      @inactive_user_groups = @inactive_user_groups.sort
      @response_groups = @response_groups.sort

      form_ids = todays_submissions.collect(&:form_id).uniq
      @recent_forms = Form.includes(:organization).find(form_ids)
    end

    def a11_v2_collections; end

    def heartbeat
      render json: {
        status: :success,
        last_request_at: user_session['last_request_at'].presence || 0,
      }
    end

    def invite
      # /views/admin/site/invite.html.erb
    end

    def invite_post
      invitee = invite_params[:refer_user]

      if invitee.present? && invitee =~ URI::MailTo::EMAIL_REGEXP && (ENV['GITHUB_CLIENT_ID'].present? ? true : APPROVED_DOMAINS.any? { |word| invitee.end_with?(word) })
        if User.exists?(email: invitee)
          redirect_to admin_invite_path, alert: "User with email #{invitee} already exists"
        else
          UserMailer.invite(current_user, invitee).deliver_later
          redirect_to admin_invite_path, notice: "Invite sent to #{invitee}"
        end
      elsif ENV['GITHUB_CLIENT_ID'].present?
        redirect_to admin_invite_path, alert: 'Please enter a valid email address'
      else
        redirect_to admin_invite_path, alert: 'Please enter a valid .gov or .mil email address'
      end
    end

    def management
      ensure_admin
      @organizations = Organization.order(:name)
      @forms = Form.non_templates
      @unmanaged_forms = @forms.order(:name)
      @agencies = Organization.order(:name)
    end

    def registry; end

    def invite_params
      params.require(:user).permit(:refer_user)
    end
  end
end
