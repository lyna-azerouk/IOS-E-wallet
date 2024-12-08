require 'sinatra'
require 'openssl'
require 'json'
require_relative '../application_controller'
require_relative '../../modal/services/dwolla/webhook'

module Webhooks
  class WebhookController < ApplicationController

    def self.receive(params)
      @user = new().find_user_by_dwolla_id(params)

      if @user.present?
        webhook = Services::Dwolla::Webhook.new(
          topic: params['topic'],
          user: @user
        )
        webhook.handel_event()
      end
    end
  end
end