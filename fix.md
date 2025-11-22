# Touchpoints Performance Fix - Action Items

## Issue Summary
- **Problem**: CPU limits causing instance crashes (50% failure rate)
- **Root Cause**: CPU-intensive JavaScript generation for form widgets on every request
- **Current Status**: 18 instances, WEB_CONCURRENCY=2, 1600M memory - still unstable

## Immediate Actions (Next 24 hours)

### 1. Further Reduce Concurrency
```bash
cf set-env touchpoints WEB_CONCURRENCY 1
cf restart touchpoints
```
**Why**: Single worker per instance reduces CPU contention
**Risk**: Lower throughput, but higher stability

### 2. Monitor Stability
- Check `cf app touchpoints` every 2 hours
- Look for crashed instances
- Monitor CPU usage patterns

## Short-term Fixes (Next 1-2 weeks)

### 3. Implement JavaScript Caching
**File**: `app/models/form.rb`
**Method**: `touchpoints_js_string`

```ruby
def touchpoints_js_string
  Rails.cache.fetch("form-js-#{short_uuid}-#{updated_at.to_i}", expires_in: 1.day) do
    ApplicationController.new.render_to_string(partial: 'components/widget/fba', formats: :js, locals: { form: self })
  end
end
```

### 4. Add Cache Invalidation
**File**: `app/models/form.rb`
**Add to**: `after_commit` callback

```ruby
after_commit do |form|
  FormCache.invalidate(form.short_uuid)
  Rails.cache.delete("form-js-#{form.short_uuid}-#{form.updated_at.to_i}")
end
```

### 5. Pre-generate Static Assets
**Goal**: Generate JavaScript files when forms are published, not on request
**Implementation**: Background job to create static `.js` files in `public/widgets/`

## Medium-term Solutions (Next 1-2 months)

### 6. CDN Integration
- Serve cached widget files from CDN
- Reduce server load for static content
- Improve global performance

### 7. Database Query Optimization
**File**: `app/models/form_cache.rb`
**Optimize**: Complex includes query
```ruby
Form.includes([:questions, { form_sections: [questions: [:question_options]] }], :organization)
```

### 8. Request CPU Limit Increase
- Contact cloud.gov support
- Request higher CPU allocation for production space
- Justify with performance metrics

## Long-term Architecture (Next 3-6 months)

### 9. Separate Widget Service
- Extract form widget delivery to dedicated microservice
- Lightweight service optimized for static content delivery
- Independent scaling from main application

### 10. Static Asset Pipeline
- Move widget generation to build-time process
- Serve widgets as static files with proper caching headers
- Eliminate runtime JavaScript generation

## Success Metrics

### Immediate Success (24 hours)
- [ ] 0% instance crash rate
- [ ] CPU usage < 20% per instance
- [ ] All 18 instances stable

### Short-term Success (2 weeks)
- [ ] JavaScript caching implemented
- [ ] 90%+ cache hit rate for widget requests
- [ ] CPU usage < 15% per instance
- [ ] Ability to reduce instance count

### Long-term Success (6 months)
- [ ] Widget delivery separated from main app
- [ ] Sub-100ms response times for widget requests
- [ ] Horizontal scaling capability
- [ ] Cost reduction from fewer required instances

## Priority Order
1. **P0**: Reduce WEB_CONCURRENCY to 1 (immediate stability)
2. **P1**: Implement JavaScript caching (eliminate CPU bottleneck)
3. **P2**: Pre-generate static assets (architectural improvement)
4. **P3**: CDN integration (performance optimization)
5. **P4**: Separate widget service (long-term scalability)
