require_relative 'api_response_helper'
require_relative 'application_controller'

class UserController < ApplicationController

  def self.create(params)
    status, message = find_resource(params)
    return [status, message] if status == 401

    transaction = Api::User::SaveTransaction.call(params: params)

    if transaction.success?
      ApiResponseHelper.render_success(200, transaction.success[:user])
    else
      ApiResponseHelper.render_failure(422, "unprocessable_entity" ,transaction.failure[:errors])
    end
  end

  def self.login(params)
    user = find_user(params)

    return 404 unless user.present?

    if user.present? && user.eq_password(params['password'])
      user.generate_session_token
      ApiResponseHelper.render_success(200, @user)
    else
      ApiResponseHelper.render_failure(401, "unauthrized")
    end
  end

  def self.authentificated(params)
    token_expired = User.token_expired?(params['session_token'])
    @user = User.find_user_by_token(params['session_token'])

    if !token_expired && @user.present?
      ApiResponseHelper.render_success(200, @user)
    else
      ApiResponseHelper.render_failure(404, "user_not_found")
    end
  end

  def self.find_resource(params)
    find_user(params)

    if @user.present?
      ApiResponseHelper.render_failure(401, "user_already_exist")
    end
  end

  def self.find_user(params)
    @user = User.find_by(email: params['email'])
    @user
  end
end
