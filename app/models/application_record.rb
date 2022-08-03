# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.tag_counts_by_name
    ActsAsTaggableOn::Tag.joins(:taggings)
      .select('tags.id, tags.name, COUNT(taggings.id) as taggings_count')
      .group('tags.id, tags.name')
      .where('taggings.taggable_type = ? and taggings.context = ? ', name, 'tags')
  end
end
