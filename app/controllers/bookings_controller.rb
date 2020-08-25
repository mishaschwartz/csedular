class BookingsController < ApplicationController

  def index
    respond_to do |format|
      format.html { render action: :index, locals: { data: format_calendar_data(Availability.data) } }
      format.json { render json: Availability.booked.data }
    end
  end

  def show
    respond_to do |format|
      format.json { render json: @booking }
    end
  end

  private

  def create_update_params
    permitted = params.permit(:availability_id, :user_id).to_h
    permitted[:creator_id] = current_user.id
    permitted
  end

  def set_attributes
    @booking = Booking.find_by(id: params[:id])
  end

  def implicit_authorization_target
    @booking || Booking
  end
end