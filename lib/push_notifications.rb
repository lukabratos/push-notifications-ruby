# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

# Pusher Push Notifications Ruby server SDK
module Pusher
  # Push Notifications Client
  class PushNotifications
    # Raised when when Push Notifications secret key is incorrect
    class PusherAuthError < StandardError
    end
    # Raised when the instance id used does not exist
    class PusherMissingInstanceError < StandardError
    end
    # Raised when the Push Notifications publish body is invalid
    class PusherValidationError < StandardError
    end
    # Raised when the Push Notifications service has an internal server error
    class PusherServerError < StandardError
    end

    # Initializes Push Notification client
    #
    # ==== Attributes
    #
    # * +instance_id+:: The unique identifier for your Push notifications
    # instance
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
      raise ArgumentError, 'Publishes must target at least one interest' if interests.empty?
      validate_interest_length(interests)
      validate_interest_characters(interests)

      res = publishes_request(interests, publish_body)
      if res.is_a?(Net::HTTPSuccess)
        return JSON.parse(res.body)['publishId']
      else
        handle_error(res)
      end
    end

    private

    # Pusher Push Notifications Ruby server SDK version
    SDK_VERSION = '0.8.0'
    # Maximum interest name length
    MAX_INTEREST_LENGTH = 164

    def base_url
      "https://#{@instance_id}.pushnotifications.pusher.com/publish_api/v1"
    end

    def publishes_url
      "#{base_url}/instances/#{@instance_id}/publishes"
    end

    def header
      header = {}
      header['Authorization'] = "Bearer #{@secret_key}"
      header['Accept'] = 'application/json'
      header['Content-Type'] = 'application/json'
      header['X-Client-SDK-Version'] = SDK_VERSION
      header
    end

    def publishes_request(interests, publish_body)
      uri = URI(publishes_url)
      http = Net::HTTP.new(uri.host)
      req = Net::HTTP::Post.new(uri.request_uri, header)
      publish_body['interests'] = interests
      req.body = publish_body.to_json
      http.request(req)
    end

    def handle_error(res)
      error_description = JSON.parse(res.body)['description']
      case res
      when Net::HTTPUnauthorized then
        raise PusherAuthError, error_description
      when Net::HTTPNotFound then
        raise PusherMissingInstanceError, error_description
      when Net::HTTPClientError then
        raise PusherValidationError, error_description
      when Net::HTTPServerError then
        raise PusherServerError, error_description
      end
    end

    def validate_interest_characters(interests)
      error_message = ' contains a forbidden character.'\
        ' Allowed characters are: ASCII upper/lower-case letters,'\
        ' numbers or one of _=@,.:'
      interest_regex = /\A[A-Za-z0-9_=@:,\\.]+\z/
      invalid_interest = interests.find { |interest| !interest[interest_regex] }
      raise ArgumentError, invalid_interest + error_message if invalid_interest
    end

    def validate_interest_length(interests)
      error_message = " is longer than the maximum of #{MAX_INTEREST_LENGTH} chars"
      invalid_interest = interests.find { |interest| interest.length > MAX_INTEREST_LENGTH }
      raise ArgumentError, invalid_interest + error_message if invalid_interest
    end
  end
end
