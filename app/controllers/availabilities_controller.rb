class AvailabilitiesController < ApplicationController
  def index
    respond_to do |format|
      format.json { render json: filter_availabilities(@resource.availabilities).data }
    end
  end

  def show
    respond_to do |format|
      format.html { redirect_to resource_path(@resource.id) }
      format.json { render json: @availability }
    end
  end

  def all
    respond_to do |format|
      format.json { render json: filter_availabilities(Availability).data }
    end
  end

  private

  def filter_availabilities(availabilities)
    availabilities = availabilities.booked if params[:booked]
    availabilities = availabilities.future if params[:future]
    availabilities = availabilities.past if params[:past]
    availabilities = availabilities.current if params[:current]
    start_after = params[:start_after].nil? ? Float::INFINITY : DateTime.parse(params[:start_after])
    start_before = params[:start_before].nil? ? Float::INFINITY : DateTime.parse(params[:start_before])
    end_after = params[:end_after].nil? ? Float::INFINITY : DateTime.parse(params[:end_after])
    end_before = params[:end_before].nil? ? Float::INFINITY : DateTime.parse(params[:end_before])
    availabilities.where(start_time: start_after...start_before, end_time: end_after...end_before)
  end

  def create_update_params
    params.permit(:resource_id).merge(params.require(:availability).permit(:start_time, :end_time))
  end

  def set_attributes
    @resource = Resource.find_by_id(params[:resource_id])
    @availability = @resource&.availabilities&.find_by(id: params[:id])
  end

  def implicit_authorization_target
    @availability || Availability
  end
end