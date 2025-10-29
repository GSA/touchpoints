use rutie::{Class, Object, RString, Hash, methods, class};

mod template_renderer;
mod form_data;

use template_renderer::TemplateRenderer;
use form_data::FormData;

class!(WidgetRenderer);

methods!(
    WidgetRenderer,
    _rtself,
    fn widget_renderer_generate_js(form_hash: Hash) -> RString {
        let hash = form_hash.unwrap();
        let form_data = FormData::from_hash(&hash);
        let renderer = TemplateRenderer::new();
        let js_content = renderer.render(&form_data);
        RString::new_utf8(&js_content)
    }
);

#[no_mangle]
pub extern "C" fn Init_widget_renderer() {
    Class::new("WidgetRenderer", None).define(|klass| {
        klass.def_self("generate_js", widget_renderer_generate_js);
    });
}
