class MySpecialError < StandardError; end


class ErrorCatchingMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
  rescue MySpecialError
    body = "Something went wrong, but at least we know the Content-Language: #{env['Content-Language'] || 'nothing found'}"
    [200, {"Content-Type" => "text/plain"}, body]
  end
end

class ContentLanguageMiddlewareBase
  def initialize(app)
    @app = app
  end

  def extract_lang_query_param(env)
    Rack::Utils.parse_nested_query(env['QUERY_STRING'])['lang']
  end
end

class WellBehavingContentLanguageMiddleware < ContentLanguageMiddlewareBase
  def call(env)
    env['Content-Language'] = extract_lang_query_param(env)
    status, headers, body = @app.call(env)
  end
end

class BadlyBehavingContentLanguageMiddleware < ContentLanguageMiddlewareBase
  def call(env)
    new_env = env.merge('Content-Language' => extract_lang_query_param(env))
    status, headers, body = @app.call(new_env)
  end
end

class ErrorRaisingApp
  def call(env)
    raise MySpecialError
  end
end
