require_relative '../rack_middleware_gotcha'
require 'rack'

describe "Well behaving middleware" do

  let(:stack) do
    app = ErrorRaisingApp.new
    ErrorCatchingMiddleware.new(WellBehavingContentLanguageMiddleware.new(app))
  end

  let(:request) { Rack::MockRequest.new(stack) }

  it "adds data to the env hash instead of creating a new one" do
    response = request.get('/?lang=en_UK')
    expect(response.body).to include ("en_UK")
  end
end

describe "Badly behaving middleware" do

  let(:stack) do
    app = ErrorRaisingApp.new
    ErrorCatchingMiddleware.new(BadlyBehavingContentLanguageMiddleware.new(app))
  end

  let(:request) { Rack::MockRequest.new(stack) }

  it "creates a new env hash" do
    response = request.get('/?lang=en_UK')
    expect(response.body).to_not include ("en_UK")
  end
end
