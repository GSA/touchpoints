# frozen_string_literal: true

require 'rutie'

module WidgetRenderer
  Rutie.new(:widget_renderer).init 'Init_widget_renderer', File.expand_path('..', __dir__)
end
