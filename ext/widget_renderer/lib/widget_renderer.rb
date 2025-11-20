# frozen_string_literal: true

require 'rutie'

module WidgetRenderer
  Rutie.new(:widget_renderer).init 'Init_widget_renderer', File.join(File.expand_path('..', __dir__), 'target', 'release')
end
