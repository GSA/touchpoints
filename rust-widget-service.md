# Immediate Rust Widget Service Solution

## Problem
- Ruby app generating JavaScript widgets on every request
- CPU-intensive ERB template rendering causing crashes
- Need immediate relief while maintaining current architecture

## Rust Solution (Can Deploy Today)

### 1. Simple Rust HTTP Service
**Purpose**: Generate JavaScript widgets 10-100x faster than Ruby
**Deployment**: Separate Cloud Foundry app alongside existing Rails app

### 2. Minimal Implementation

```rust
// Cargo.toml
[package]
name = "touchpoints-widget-service"
version = "0.1.0"
edition = "2021"

[dependencies]
axum = "0.7"
tokio = { version = "1.0", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
tera = "1.19"
sqlx = { version = "0.7", features = ["runtime-tokio-rustls", "postgres"] }

// src/main.rs
use axum::{
    extract::{Path, Query},
    http::StatusCode,
    response::{Html, Response},
    routing::get,
    Router,
};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use tera::{Context, Tera};

#[derive(Deserialize)]
struct FormData {
    short_uuid: String,
    name: String,
    questions: Vec<Question>,
    // ... other form fields
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/touchpoints/:id.js", get(generate_widget_js));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8080").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn generate_widget_js(Path(form_id): Path<String>) -> Result<Response<String>, StatusCode> {
    // 1. Fetch form data from Rails API or shared database
    let form_data = fetch_form_data(&form_id).await?;
    
    // 2. Render JavaScript template (10-100x faster than ERB)
    let js_content = render_widget_template(&form_data)?;
    
    // 3. Return with proper headers
    Ok(Response::builder()
        .header("content-type", "application/javascript")
        .header("cache-control", "public, max-age=3600")
        .body(js_content)
        .unwrap())
}
```

### 3. Template (Tera - similar to ERB)
```javascript
// templates/widget.js
'use strict';
function FBAform(d, N) {
    return {
        formComponent: function() {
            return d.querySelector("[data-touchpoints-form-id='{{ form.short_uuid }}']")
        },
        // ... rest of widget logic with {{ }} template variables
    };
}

var touchpointFormOptions{{ form.short_uuid }} = {
    'formId': "{{ form.short_uuid }}",
    'modalButtonText': "{{ form.modal_button_text }}",
    // ... other options
};
```

## Immediate Deployment Plan

### Step 1: Deploy Rust Service (2-4 hours)
```bash
# Create new CF app
cf push touchpoints-widgets -b rust_buildpack -m 128M -i 2

# Route widget requests to Rust service
cf map-route touchpoints-widgets touchpoints.app.cloud.gov --path /touchpoints/*.js
```

### Step 2: Update Rails Routes (30 minutes)
```ruby
# config/routes.rb - comment out existing route
# get '/touchpoints/:id', to: 'touchpoints#show', format: 'js'

# Add fallback for non-JS requests
get '/touchpoints/:id', to: 'touchpoints#show', constraints: ->(req) { !req.format.js? }
```

### Step 3: Data Access Options

**Option A: API Endpoint (Fastest to implement)**
```ruby
# Add to Rails app - new API endpoint
class Api::FormsController < ApplicationController
  def show
    form = FormCache.fetch(params[:id])
    render json: form.as_json(include: [:questions, :form_sections])
  end
end
```

**Option B: Shared Database (Better performance)**
- Rust service connects directly to same PostgreSQL database
- Read-only access to forms, questions, form_sections tables

## Expected Performance Gains

### Current Ruby Performance
- **Response Time**: 100-500ms per widget request
- **CPU Usage**: 26-35% per instance
- **Memory**: 500-700MB per instance
- **Throughput**: ~10-50 requests/second per instance

### Rust Service Performance
- **Response Time**: 1-10ms per widget request
- **CPU Usage**: 1-5% per instance
- **Memory**: 10-50MB per instance  
- **Throughput**: 1000+ requests/second per instance

## Immediate Benefits
1. **Instant Relief**: Offload CPU-intensive widget generation from Ruby
2. **Cost Reduction**: 1-2 Rust instances can replace 18 Ruby instances for widget serving
3. **Stability**: Ruby app no longer crashes from widget request load
4. **Scalability**: Rust service can handle 10-100x more traffic

## Implementation Timeline
- **Hour 1**: Create basic Rust service with template rendering
- **Hour 2**: Add form data fetching (API or database)
- **Hour 3**: Deploy to Cloud Foundry and test
- **Hour 4**: Route production traffic and monitor

## Risk Mitigation
- **Fallback**: Keep existing Ruby widget generation as backup
- **Gradual Rollout**: Route 10% of traffic initially, then increase
- **Monitoring**: Track response times and error rates
- **Rollback Plan**: Can revert routing in seconds if issues arise

This solution provides immediate relief while maintaining the existing Rails architecture.
