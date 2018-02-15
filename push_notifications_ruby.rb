# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

# Pusher Push Notifications Ruby server SDK
module Pusher
  # Push Notifications Client
  class PushNotifications
    # The unique identifier for your Push notifications instance
    attr_accessor :instance_id
    # Push Notifications instance secret key
    attr_accessor :secret_key

    # Initializes Push Notification client
    #
    # ==== Attributes
    #
    # * +instance_id+:: The unique identifier for your Push notifications instance
    # * +secret_key+:: Push Notifications instance secret key
    #
    # ==== Examples
    #
    #    instance_id = '97c56dfe-58f5-408b-ab3a-158e51a860f2'
    #    secret_key = '6033364526F02EDEF472461879CE485'
    #
    #    pusher = Pusher::PushNotifications.new(instance_id, scecret_key)
    def initialize(instance_id, secret_key)
      @instance_id = instance_id
      @secret_key = secret_key
    end

    # Publish a push notification to your registered & subscribed devices
    #
    # ==== Attributes
    #
    # * +interests+:: Array of interests that you want to subscribe to
    # * +publish_body+:: Hash containing the body of the publish request
    #
    # ==== Examples
    #
    #    publish_body = {
    #      'apns': {
    #        'aps': {
    #          'alert': 'Hello!'
    #        }
    #      }
    #    }
    #
    #    interests = %w[luka pizza]
    #    pusher.publish(interests, publish_body)
    def publish(interests, publish_body)
      response = publishes_request(interests, publish_body)
      puts JSON.parse(response.body)['publishId']
    end

    private

    def base_url
      "https://#{instance_id}.pushnotifications.pusher.com/publish_api/v1"
    end

    def publishes_url
      "#{base_url}/instances/#{instance_id}/publishes"
    end

    def header
      header = {}
      header['Authorization'] = "Bearer #{secret_key}"
      header['Accept'] = 'application/json'
      header['Content-Type'] = 'application/json'
      header
    end

    def publishes_request(interests, publish_body)
      uri = URI(publishes_url)
      http = Net::HTTP.new(uri.host)
      request = Net::HTTP::Post.new(uri.request_uri, header)
      publish_body['interests'] = interests
      request.body = publish_body.to_json
      http.request(request)
    end
  end
end

instance_id = '97c56dfe-58f5-408b-ab3a-158e51a860f2'
secret_key = '6033364526F02EDEF472461879CE485'

pusher = Pusher::PushNotifications.new(instance_id, secret_key)

publish_body = {
  'apns': {
    'aps': {
      'alert': 'Hello!'
    }
  }
}

pusher.publish(%w[luka test], publish_body)
