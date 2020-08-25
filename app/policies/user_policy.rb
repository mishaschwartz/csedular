class UserPolicy < ApplicationPolicy
  def login?
    !Rails.configuration.remote_user_auth
  end

  def logout?
    !Rails.configuration.remote_user_auth
  end

  def show?
    check?(:admin?) || check?(:current_user_is_user?)
  end

  def index?
    check?(:admin?)
  end

  def reset_api_key?
    check?(:admin?) && check?(:current_user_is_user?)
  end

  def current_user_is_user?
    record&.id == user.id
  end

  def update_permissions?
    check?(:admin?)
  end
end
