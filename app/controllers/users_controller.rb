class UsersController < ApplicationController

  def login
    if current_user.nil?
      user = User.find_by(username: login_params[:username])
      if user.nil? || !validate_user(user, login_params[:password])
        flash[:error] = t('views.users.login.invalid') if request.post?
        render :login, locals: { username: login_params[:username] }
      else
        session[:user_id] = user.id
        redirect_to root_path
      end
    else
      redirect_to root_path
    end
  end

  def logout
    clear_session
    redirect_to action: :login
  end

  def show
    @user ||= current_user
    if @user.client
      @calendar_data = format_calendar_data(@user.availabilities.data + Availability.future.bookable.data)
    end
    respond_to do |format|
      format.html
      format.json { render json: User.where(id: params[:id]).data.first }
    end
  end

  def index
    @data = User.all.data
    respond_to do |format|
      format.html
      format.json { render json: @data }
    end
  end

  def reset_api_key
    current_user.regenerate_api_key
    respond_to do |format|
      format.html { redirect_to action: :show }
      format.json { render json: { new_api_key: current_user.reload.api_key } }
    end
  end

  def update_permissions
    if @user.update(permissions_params)
      respond_to do |format|
        format.json { render json: @user, status: :ok }
      end
    end
  end

  private

  def login_params
    params.permit(:username, :password)
  end

  def create_update_params
    params.require(:user).permit(:username, :display_name, :email)
  end

  def permissions_params
    params.require(:user).permit(:admin, :client, :read_only)
  end

  def validate_user(user, password)
    return false if password.strip.blank? || !user.active?

    not_allowed_regexp = Regexp.new(/[\n\0]+/)
    return false if not_allowed_regexp.match(user.username) || not_allowed_regexp.match(password)

    pipe = IO.popen("'#{Rails.configuration.validation_script}'", 'w+') # quotes to avoid choking on spaces
    to_stdin = [user.username, password].join("\n")
    pipe.puts(to_stdin)
    pipe.close
    $?.exitstatus == 0
  end

  def set_attributes
    @user = User.find_by_id(params[:id])
  end

  protected

  def do_authorize
    action_name != 'login'
  end

  def implicit_authorization_target
    @user || current_user
  end
end
