# frozen_string_literal: true

class FullFormSerializer < FormSerializer
  attributes :page, :size, :start_date, :end_date

  def page
    @instance_options[:page]
  end

  def size
    @instance_options[:size]
  end

  def start_date
    @instance_options[:start_date]
  end

  def end_date
    @instance_options[:end_date]
  end

  def links
    @instance_options[:links]
  end

  has_many :submissions

  def submissions
    object.submissions.order(:id).where('created_at BETWEEN ? AND ?', start_date, end_date).limit(size).offset(size * page)
  end
end
