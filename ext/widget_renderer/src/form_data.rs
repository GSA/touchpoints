use serde::Deserialize;
use serde::de::{self, Deserializer};

fn deserialize_bool<'de, D>(deserializer: D) -> Result<bool, D::Error>
where
    D: Deserializer<'de>,
{
    // Treat null or missing as false to match legacy Rails data that may serialize nil booleans.
    Option::<bool>::deserialize(deserializer).map(|v| v.unwrap_or(false))
}

#[derive(Deserialize)]
pub struct FormData {
    pub short_uuid: String,
    pub modal_button_text: String,
    pub element_selector: String,
    pub delivery_method: String,
    #[serde(default, deserialize_with = "deserialize_bool")]
    pub load_css: bool,
    pub success_text_heading: String,
    pub success_text: String,
    #[serde(default, deserialize_with = "deserialize_bool")]
    pub suppress_submit_button: bool,
    #[serde(default, deserialize_with = "deserialize_bool")]
    pub suppress_ui: bool,
    pub kind: String,
    #[serde(default, deserialize_with = "deserialize_bool")]
    pub enable_turnstile: bool,
    #[serde(default, deserialize_with = "deserialize_bool")]
    pub has_rich_text_questions: bool,
    #[serde(default, deserialize_with = "deserialize_bool")]
    pub verify_csrf: bool,
    pub title: Option<String>,
    pub instructions: Option<String>,
    pub disclaimer_text: Option<String>,
    pub logo_url: Option<String>,
    pub logo_class: Option<String>,
    pub omb_approval_number: Option<String>,
    pub expiration_date: Option<String>,
    #[serde(default)]
    pub css: String,
    #[serde(skip, default)]
    pub prefix: String,
    pub questions: Vec<Question>,
}

#[derive(Deserialize)]
pub struct Question {
    pub answer_field: String,
    pub question_type: String,
    pub question_text: Option<String>,
    #[serde(default, deserialize_with = "deserialize_bool")]
    pub is_required: bool,
}

impl FormData {
    pub fn compute_prefix(&mut self) {
        self.prefix = if self.load_css { "fba".to_string() } else { String::new() };
    }
}
