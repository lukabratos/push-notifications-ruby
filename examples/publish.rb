require 'pusher_push_notifications'

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
