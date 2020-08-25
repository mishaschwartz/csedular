class ResourcesController < ApplicationController

  def index
    @data = Resource.joins(:location).pluck_to_hash(*%w[name resource_type locations.name locations.id resources.id])
    respond_to do |format|
      format.html
      format.json { render json: @data }
    end
  end

  def show
    if allowed_to?(:admin?)
      data = Availability.where(resource: @resource).data
      @calendar_data = format_calendar_data(data, delete_availabilites: true)
    end
    respond_to do |format|
      format.html
      format.json { render json: @resource.to_json }
    end
  end

  def current
    respond_to do |format|
      format.json { render json: @resource.availabilities.current.data.first  }
    end
  end

  private

  def create_update_params
    params.require(:resource).permit(:resource_type, :name, :location_id)
  end

  def set_attributes
    @resource = Resource.find_by_id(params[:id])
  end

  def implicit_authorization_target
    @resource || Resource
  end
end