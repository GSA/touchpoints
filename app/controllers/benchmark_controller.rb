class BenchmarkController < ApplicationController
  # Benchmark endpoints are only available in development mode
  before_action :ensure_development_environment
  
  def widget_benchmark
    require 'benchmark'
    
    form = Form.find(8)
    iterations = 100
    
    time = Benchmark.measure do
      iterations.times { form.touchpoints_js_string }
    end
    
    avg_ms = (time.real * 1000) / iterations
    
    render json: {
      iterations: iterations,
      total_ms: (time.real * 1000).round(2),
      avg_ms: avg_ms.round(3),
      throughput: (iterations / time.real).round(2),
      using_rust: defined?(WidgetRenderer) ? true : false
    }
  end

  def widget_http_benchmark
    require 'benchmark'
    require 'net/http'
    
    # Find a valid form for testing
    form = Form.find(8)
    url = "http://localhost:3000/touchpoints/#{form.short_uuid}.js"
    iterations = 50 # Fewer iterations for HTTP tests
    
    # Warm up
    Net::HTTP.get(URI(url))
    
    time = Benchmark.measure do
      iterations.times do
        Net::HTTP.get(URI(url))
      end
    end
    
    avg_ms = (time.real * 1000) / iterations
    
    render json: {
      iterations: iterations,
      total_ms: (time.real * 1000).round(2),
      avg_ms: avg_ms.round(3),
      throughput: (iterations / time.real).round(2),
      using_rust: defined?(WidgetRenderer) ? true : false,
      test_type: 'http_request',
      url: url
    }
  end

  private

  def ensure_development_environment
    unless Rails.env.development?
      render json: { error: 'Benchmark endpoints are only available in development mode' }, status: :forbidden
    end
  end
end
