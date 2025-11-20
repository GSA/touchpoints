use rutie::{Class, Object, RString, methods, class, AnyObject};
use serde_json;

mod template_renderer;
mod form_data;

use template_renderer::TemplateRenderer;
use form_data::FormData;

class!(WidgetRenderer);

methods!(
    WidgetRenderer,
    _rtself,
    fn widget_renderer_generate_js(arg: AnyObject) -> RString {
        let arg = arg.unwrap();
        
        // Cast to RString, assuming input is String
        let rstring = RString::from(arg.value());
        let json_str = rstring.to_string();
        
        let form_data_result: Result<FormData, _> = serde_json::from_str(&json_str);
        
        match form_data_result {
            Ok(mut form_data) => {
                form_data.compute_prefix();
                let renderer = TemplateRenderer::new();
                let js_content = renderer.render(&form_data);
                RString::new_utf8(&js_content)
            },
            Err(e) => {
                let msg = format!("Rust Error: Failed to parse JSON. Error: {:?}", e);
                RString::new_utf8(&format!("/* {} */", msg))
            }
        }
    }
);

#[no_mangle]
pub extern "C" fn Init_widget_renderer() {
    Class::new("WidgetRenderer", None).define(|klass| {
        klass.def_self("generate_js", widget_renderer_generate_js);
    });
}

