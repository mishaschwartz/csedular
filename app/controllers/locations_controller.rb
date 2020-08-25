class LocationsController < ApplicationController

  def show
    if allowed_to?(:admin?)
      data = Availability.joins(resource: :location)
                         .where('locations.id': @location)
                         .data
      @calendar_data = format_calendar_data(data)
    end
    respond_to do |format|
      format.html
      format.json { render json: @location.to_json }
    end
  end

  def index
    @data = Location.pluck_to_hash(*%w[name description id])
    respond_to do |format|
      format.html
      format.json { render json: @data }
    end
  end

  private

  def create_update_params
    params.require(:location).permit(:name, :description)
  end

  def set_attributes
    @location = Location.find_by_id(params[:id])
  end

  def implicit_authorization_target
    @location || Location
  end
end