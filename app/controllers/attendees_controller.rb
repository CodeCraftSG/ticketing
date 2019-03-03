class AttendeesController < ApplicationController
  before_action :get_attendee

  def show
  end

  def update
    begin
      @attendee.update!(attendee_params)
      flash.now[:success] = 'Your particulars have been updated.'
    rescue => e
      Rails.logger.error "Exception: Unable to save attendee (#{e.message}) for #{params}"
      flash.now[:error] = e.message
      render :show
    end
  end

  private

  def get_attendee
    @attendee = Attendee.find_by(public_id: params[:id])
  end

  def attendee_params
    params.require(:attendee).permit(:first_name, :last_name, :email, :cutting, :size, :dietary_pref, :twitter, :github)
  end
end
