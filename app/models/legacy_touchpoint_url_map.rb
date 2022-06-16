class LegacyTouchpointUrlMap
  ## Create a hash map of legacy Touchpoint id and short_uuid routes to new Form.short_uuid
  def self.map
    legacy_map = {}
    Form.all.each do |form|
      if form.legacy_touchpoint_id
        legacy_map[form.legacy_touchpoint_id.to_s] = form.short_uuid
      end

      if form.legacy_touchpoint_uuid
        legacy_map[form.legacy_touchpoint_uuid[0..7].to_s] = form.short_uuid
      end
    end

    legacy_map
  end
end
