class ApplicationController < ActionController::Base
  before_action :authenticate, except: [:login]
  before_action :set_attributes
  before_action { authorize! if do_authorize }
  after_action :refresh_timeout
  skip_before_action :verify_authenticity_token, unless: -> { api_key.blank? }

  rescue_from ActionPolicy::Unauthorized, with: -> { head :forbidden }
  rescue_from ActiveRecord::RecordNotFound, with: -> { head :not_found }

  # shared routes

  def new
    name = :"@#{controller_name.classify.downcase}"
    self.instance_variable_set(name, controller_name.classify.constantize.new)
  end

  def edit
  end

  def create
    model = controller_name.classify.constantize.new(create_update_params)
    if model.save
      flash[:success] = 'success'
      respond_to do |format|
        format.js
        format.html { redirect_to action: :show, id: model.id }
        format.json { render json: model.reload, status: :ok }
      end
    else
      flash[:error] = model.errors.full_messages.join(', ')
      respond_to do |format|
        format.js
        format.html { redirect_to action: :new }
        format.json { render json: { errors: model.errors.full_messages }, status: :bad_request }
      end
    end
  end

  def update
    name = :"@#{controller_name.classify.downcase}"
    model = self.instance_variable_get(name)
    if model.update(create_update_params)
      respond_to do |format|
        format.html { redirect_to action: :show, id: model.id }
        format.json { render json: model.reload, status: :ok }
      end
    else
      flash[:error] = model.errors.full_messages.join(', ')
      respond_to do |format|
        format.html { redirect_to action: :edit, id: model.id }
        format.json { render json: { errors: model.errors.full_messages }, status: :bad_request }
      end
    end
  end

  def destroy
    name = :"@#{controller_name.classify.downcase}"
    model = self.instance_variable_get(name)
    model.destroy
    if model.destroyed?
      respond_to do |format|
        format.js { flash[:success] = 'success' }
        format.json { render json: model.reload, status: :ok }
        format.html do
          flash[:success] = 'success'
          redirect_to action: :index
        end
      end
    else
      respond_to do |format|
        format.js { flash[:error] = model.errors.full_messages.join(', ') }
        format.json { render json: { errors: model.errors.full_messages }, status: :bad_request }
        format.html do
          flash[:error] = model.errors.full_messages.join(', ')
          redirect_back(fallback_location: root_path)
        end
      end
    end
  end

  protected

  def authenticate
    if Rails.configuration.remote_user_auth
      @current_user = request.env[Rails.configuration.remote_user_key]
    elsif !api_key.blank?
      @current_user = User.find_by_api_key(api_key)
      render json: { status: 403 }, status: :forbidden if @current_user.nil? || !allowed_to?(:access_api?)
    elsif current_user.nil? || session_expired?
      clear_session
      redirect_to controller: :users, action: :login
    end
  end

  def session_expired?
    session[:timeout].nil? || Time.parse(session[:timeout]) < Time.current
  end

  def clear_session
    session[:timeout] = nil
    session[:user_id] = nil
    cookies.delete :auth_token
    reset_session
  end

  def refresh_timeout
    session[:timeout] = Rails.configuration.session_timeout.seconds.from_now.to_s
  end

  def api_key
    @api_key ||= request.headers['HTTP_AUTHORIZATION']&.[](/CsedulerAuth ([^\s,]+)/, 1)
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def do_authorize
    action_name != 'login'
  end

  def set_attributes
    raise NotImplementedError
  end

  def format_calendar_data(data, delete_availabilites: false)
    time_groups = Hash.new { |hash, key| hash[key] = Set.new }
    location_groups = Hash.new { |hash, key| hash[key] = [] }
    resource_groups = Hash.new { |hash, key| hash[key] = [] }
    client_groups = Hash.new { |hash, key| hash[key] = [] }
    grouped_data = ActiveSupport::OrderedHash.new
    format = '%Y/%-m/%-d'
    dates = []
    cancelable_ids = get_cancellable_ids
    data.each do |h|
      h[:can_cancel] = cancelable_ids.include? h[:availability_id]
      h[:can_delete_availability] = h[:start_time] > Time.now
      availability_id = h[:availability_id]
      time_groups[h[:start_time].strftime(format)] << availability_id
      time_groups[h[:end_time].strftime(format)] << availability_id
      location_groups[h[:location_name]] << availability_id
      resource_groups[h[:resource_type]] << availability_id
      client_groups[h[:username]] << availability_id
      grouped_data[h[:availability_id]] = h
      dates << h[:start_time]
      dates << h[:end_time]
    end
    { data: grouped_data,
      time_groups: time_groups.transform_values(&:uniq),
      date_format: format,
      user_id: @user&.id,
      show_booking_button: allowed_to?(:see_booking_button?),
      location_groups: location_groups,
      location_label: t('activerecord.models.location'),
      resource_groups: resource_groups,
      resource_label: t('shared.calendar.resource_type'),
      client_groups: client_groups,
      client_label: t('shared.calendar.booked_by'),
      filter_options: { all: t('shared.calendar.all_records'), null: t('shared.calendar.null_records') },
      min_date: dates.min || Time.now,
      max_date: dates.max || Time.now,
      delete_availabilities: delete_availabilites }
  end

  def get_cancellable_ids
    return Set.new unless allowed_to?(:see_cancel_button?)
    return Set.new(Availability.booked.future.ids) if allowed_to?(:admin?)
    Set.new(Availability.booked.cancelable.ids)
  end
end
