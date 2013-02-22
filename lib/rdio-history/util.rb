module Rdio
  module API
    API_BASE_URL = 'www.rdio.com'

    # API Resource URLs
    HISTORY_PATH    = '/api/1/getHistoryForUser'
    USER_PATH       = '/api/1/getObjectFromUrl'
    SIGNIN_PATH     = '/api/1/signIn'
    HOME_PATH       = '/'

    # API rest methods
    HISTORY_METHOD = 'getHistoryForUser'
    USER_METHOD    = 'getObjectFromUrl'
    SIGNIN_METHOD  = 'signIn'
  end
end
