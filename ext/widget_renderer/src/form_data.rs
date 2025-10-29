use rutie::{Hash, RString, Symbol, Boolean};

pub struct FormData {
    pub short_uuid: String,
    pub modal_button_text: String,
    pub element_selector: String,
    pub delivery_method: String,
    pub load_css: bool,
    pub success_text_heading: String,
    pub success_text: String,
    pub suppress_submit_button: bool,
    pub suppress_ui: bool,
    pub kind: String,
    pub enable_turnstile: bool,
    pub has_rich_text_questions: bool,
    pub verify_csrf: bool,
    pub prefix: String,
    pub questions: Vec<Question>,
}

pub struct Question {
    pub answer_field: String,
    pub question_type: String,
}

impl FormData {
    pub fn from_hash(hash: &Hash) -> Self {
        FormData {
            short_uuid: get_string_from_hash(hash, "short_uuid"),
            modal_button_text: get_string_from_hash(hash, "modal_button_text"),
            element_selector: get_string_from_hash(hash, "element_selector"),
            delivery_method: get_string_from_hash(hash, "delivery_method"),
            load_css: get_bool_from_hash(hash, "load_css"),
            success_text_heading: get_string_from_hash(hash, "success_text_heading"),
            success_text: get_string_from_hash(hash, "success_text"),
            suppress_submit_button: get_bool_from_hash(hash, "suppress_submit_button"),
            suppress_ui: get_bool_from_hash(hash, "suppress_ui"),
            kind: get_string_from_hash(hash, "kind"),
            enable_turnstile: get_bool_from_hash(hash, "enable_turnstile"),
            has_rich_text_questions: get_bool_from_hash(hash, "has_rich_text_questions"),
            verify_csrf: get_bool_from_hash(hash, "verify_csrf"),
            prefix: get_string_from_hash(hash, "prefix"),
            questions: get_questions_from_hash(hash),
        }
    }
}

fn get_string_from_hash(hash: &Hash, key: &str) -> String {
    let symbol = Symbol::new(key);
    let value = hash.at(&symbol);
    if let Ok(string_val) = value.try_convert_to::<RString>() {
        string_val.to_string()
    } else {
        String::new()
    }
}

fn get_bool_from_hash(hash: &Hash, key: &str) -> bool {
    let symbol = Symbol::new(key);
    let value = hash.at(&symbol);
    if let Ok(bool_val) = value.try_convert_to::<Boolean>() {
        bool_val.to_bool()
    } else if let Ok(string_val) = value.try_convert_to::<RString>() {
        string_val.to_string() == "true"
    } else {
        false
    }
}

fn get_questions_from_hash(_hash: &Hash) -> Vec<Question> {
    // For now, return empty vec - we'll implement this later
    Vec::new()
}
