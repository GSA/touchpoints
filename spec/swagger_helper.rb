# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where OpenAPI files are generated
  config.openapi_root = Rails.root.join('public/api').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/openapi.yml' => {
      openapi: '3.0.1',
      info: {
        title: 'Touchpoints API',
        description: 'Touchpoints makes customer feedback easier for federal agencies,
and the Touchpoints API provides a convenient, programmatic way to access the data for your forms, responses, and other Customer Experience (CX) related domain objects.',
        version: 'v1',
        contact: {
          name: 'Touchpoints Support',
          url: 'https://touchpoints.digital.gov/',
          email: 'feedback-analytics@gsa.gov'
        }
      },
      tags: [
        {
          name: 'Forms',
          description: "
Forms (also called surveys) are used to collect user feedback. With a Touchpoints account, you can
create a form, publish it in one of several digital formats and view form responses submitted by your users. You can also share
your form with other Touchpoints users so that it may be managed collectively by your team.

Use the following endpoints to view your forms and form responses. Normal users can see forms for which they are a Form Manager or Response Viewer. Users with the Organization Admin role can see all forms belonging to their organization.

Forms are identified by their short UUID, which is the 8-character string of letters and numbers used in Touchpoints form URLs. For instance, if your form lives at https://touchpoints.app.cloud.gov/admin/forms/8fc3c208, its short UUID is '8fc3c208'.

Note that all Form endpoints are read-only. To create, edit or share a form, you must use the [Touchpoints web app](https://touchpoints.app.cloud.gov/).
",
        },
        {
          name: 'Services',
        },
        {
          name: 'CX Collections',
        },
        {
          name: 'Digital Registry',
        },
      ],
      servers: [
        {
          url: 'http://localhost:3000/api',
          description: 'Local development server',
        },
        {
          url: 'https://api.gsa.gov/analytics/touchpoints',
          description: 'The API gateway that hosts the production Touchpoints API',
        },
      ],
      components: {
        securitySchemes: {
          api_key: {
            type: :apiKey,
            name: 'x-api-key',
            in: :header,
          },
        },
        schemas: {
          CxCollectionResource: {
            type: 'object',
            description: "Represents a fiscal quarter's worth of CX feedback submitted for a specific service. Feedback can be collected via multiple channels/surveys and at multiple service journey stages.",
            required: %w[id type attributes],
            properties: {
              id: {
                type: 'string',
                description: 'Numeric identifier of the CX collection (string-encoded).',
              },
              type: {
                type: 'string',
                enum: ['cx_collections'],
                example: 'cx_collections',
              },
              attributes: {
                '$ref': '#/components/schemas/CxCollectionAttributes',
              },
            },
          },

          CxCollectionAttributes: {
            type: 'object',
            required: %w[user_id name organization_id service_provider_id service_id service_name fiscal_year quarter aasm_state created_at updated_at],
            properties: {
              user_id: {
                type: 'integer',
                description: 'ID of the user who created the collection.',
              },
              name: {
                type: 'string',
                description: 'Display name of the collection.',
                example: 'CX Quarterly Reporting',
              },
              organization_id: {
                type: 'integer',
                description: 'ID of the organization associated with this collection.',
              },
              service_provider_id: {
                type: 'integer',
                description: 'ID of the service provider associated with this collection.',
              },
              service_id: {
                type: 'integer',
                description: 'ID of the service being reported on.',
              },
              service_name: {
                type: 'string',
                description: 'Display name of the service being reported on.',
                example: 'Applying for direct and guaranteed real estate and operating loans to start, maintain, and expand a family farm',
              },
              fiscal_year: {
                type: 'string',
                pattern: '^[0-9]{4}$',
                description: 'Federal fiscal year for this reporting period (string-encoded four-digit year).',
                example: '2024',
              },
              quarter: {
                type: 'string',
                enum: %w[1 2 3 4],
                description: 'Federal fiscal quarter for this reporting period (string-encoded).',
                example: '2',
              },
              aasm_state: {
                type: 'string',
                enum: %w[draft submitted published not_reported change_requested archived],
                description: 'Current workflow state of the collection record.',
                example: 'published',
              },
              rating: {
                type: 'string',
                nullable: true,
                description: "Overall rating for the collection. 'TRUE' denotes green, 'PARTIAL' is yellow, 'FALSE' means red. Null or empty string if not yet rated.",
                example: 'TRUE',
              },
              integrity_hash: {
                type: 'string',
                nullable: true,
                description: 'Hash used to verify data integrity of the submitted collection. Null if not yet computed.',
              },
              created_at: {
                type: 'string',
                format: 'date-time',
                description: 'ISO 8601 timestamp when the collection was created.',
                example: '2024-03-26T20:46:03.778Z',
              },
              submitted_at: {
                type: 'string',
                format: 'date-time',
                nullable: true,
                description: 'ISO 8601 timestamp when the collection was submitted. Null if not yet submitted.',
                example: '2024-06-12T15:38:13.751Z',
              },
              updated_at: {
                type: 'string',
                format: 'date-time',
                description: 'ISO 8601 timestamp when the collection was last updated.',
                example: '2024-06-12T15:38:25.098Z',
              },
            },
          },
          
          CxCollectionDetailResource: {
            type: 'object',
            description: 'Represents CX feedback collected via a single channel at a single service journey stage for a CX Collection.',
            required: %w[id type attributes],
            properties: {
              id: {
                type: 'string',
                description: 'Numeric identifier of the CX collection detail (string-encoded).',
              },
              type: {
                type: 'string',
                enum: ['cx_collection_details'],
              },
              attributes: {
                '$ref': '#/components/schemas/CxCollectionDetailAttributes',
              },
            },
          },

          CxCollectionDetailAttributes: {
            type: 'object',
            required: %w[cx_collection_id service_id service_name service_provider_id service_provider_name channel service_stage_id service_stage_name volume_of_customers_provided_survey_opportunity volume_of_respondents omb_control_number survey_type survey_title trust_question_text created_at updated_at],
            properties: {
              cx_collection_id: {
                type: 'integer',
                description: 'Foreign key referencing the parent CX collection record.',
              },
              service_id: {
                type: 'integer',
                description: 'ID of the service being measured.',
              },
              service_name: {
                type: 'string',
                description: 'Display name of the service being measured.',
                example: 'Simplifying the USAID partnership process',
              },
              service_provider_id: {
                type: 'integer',
                description: 'ID of the service provider associated with this detail.',
              },
              service_provider_name: {
                type: 'string',
                description: 'Display name of the service provider associated with this detail.',
                example: 'U.S. Agency for International Development',
              },
              channel: {
                type: 'string',
                enum: %w[computer mobile email chatbot phone automated_phone in_person paper postal_mail fax self_service_kiosk other_non_digital website mobile_app live_chat sms_text_messages social_media other_digital],
                description: 'Delivery channel through which the survey was administered.',
                example: 'website',
              },
              service_stage_id: {
                type: 'integer',
                description: 'ID of the service journey stage at which the survey was administered.',
                nullable: true,
              },
              service_stage_name: {
                type: 'string',
                description: "Display name of the service journey stage (e.g. 'Beg', 'Middle', 'End').",
                example: 'End',
                nullable: true,
              },
              volume_of_customers: {
                type: 'integer',
                nullable: true,
                description: 'Total number of customers who interacted with the service during the reporting period. Null if not reported.',
              },
              volume_of_customers_provided_survey_opportunity: {
                type: 'integer',
                description: 'Number of customers who were offered the opportunity to complete the survey.',
              },
              volume_of_respondents: {
                type: 'integer',
                description: 'Number of customers who completed the survey.',
              },
              omb_control_number: {
                type: 'string',
                description: 'OMB Paperwork Reduction Act control number for the survey instrument.',
                example: '0412-0601',
              },
              survey_type: {
                type: 'string',
                enum: %w[likert_scale thumbs_up_down],
                description: 'Response format used by the survey instrument.',
                example: 'thumbs_up_down',
              },
              survey_title: {
                type: 'string',
                description: 'Title of the survey instrument.',
                example: 'USAID Pre-Engagement Assessment Post Transaction Survey',
              },
              trust_question_text: {
                type: 'string',
                description: 'Verbatim text of the trust question posed to respondents.',
                example: 'The assessment increased my trust in the USAID partnership process.',
              },
              created_at: {
                type: 'string',
                format: 'date-time',
                description: 'ISO 8601 timestamp when the detail record was created.',
                example: '2024-04-04T00:51:25.360Z',
              },
              updated_at: {
                type: 'string',
                format: 'date-time',
                description: 'ISO 8601 timestamp when the detail record was last updated.',
                example: '2024-04-05T22:32:58.344Z',
              },
            },
          },

          CxResponseResource: {
            type: 'object',
            description: "Response to a CX collection detail survey, representing a single respondent's answers to the survey questions.",
            required: %w[id type attributes],
            properties: {
              id: {
                type: 'string',
                description: 'Numeric identifier of the CX response (string-encoded).',
                example: '598211',
              },
              type: {
                type: 'string',
                enum: ['cx_responses'],
                example: 'cx_responses',
              },
              attributes: {
                '$ref': '#/components/schemas/CxResponseAttributes',
              },
            },
          },

          CxResponseAttributes: {
            type: 'object',
            required: %w[cx_collection_detail_id cx_collection_detail_upload_id question_1 positive_effectiveness positive_ease positive_efficiency positive_transparency positive_humanity positive_employee positive_other negative_effectiveness negative_ease negative_efficiency negative_transparency negative_humanity negative_employee negative_other job_id created_at updated_at external_id],
            properties: {
              cx_collection_detail_id: {
                type: 'integer',
                description: 'Foreign key referencing the CX collection detail record.',
              },
              cx_collection_detail_upload_id: {
                type: 'integer',
                description: 'Foreign key referencing the batch upload that produced this response.',
              },
              question_1: {
                type: 'string',
                enum: %w[0 1],
                description: "Binary satisfaction response — '1' for positive, '0' for negative (string-encoded).",
                example: '1',
              },
              positive_effectiveness: {
                type: 'string',
                enum: %w[0 1],
                description: 'Whether the respondent cited effectiveness as a positive factor.',
                example: '1',
              },
              positive_ease: {
                type: 'string',
                enum: %w[0 1],
                description: 'Whether the respondent cited ease as a positive factor.',
                example: '0',
              },
              positive_efficiency: {
                type: 'string',
                enum: %w[0 1],
                description: 'Whether the respondent cited efficiency as a positive factor.',
                example: '0',
              },
              positive_transparency: {
                type: 'string',
                enum: %w[0 1],
                description: 'Whether the respondent cited transparency as a positive factor.',
                example: '0',
              },
              positive_humanity: {
                type: 'string',
                enum: %w[0 1 null],
                description: "Whether the respondent cited humanity as a positive factor. 'null' (string) indicates the dimension was not applicable for this collection.",
                example: 'null',
              },
              positive_employee: {
                type: 'string',
                enum: %w[0 1 null],
                description: "Whether the respondent cited employee as a positive factor. 'null' (string) indicates the dimension was not applicable for this collection.",
                example: 'null',
              },
              positive_other: {
                type: 'string',
                enum: %w[0 1 null],
                description: "Whether the respondent cited other as a positive factor. 'null' (string) indicates the dimension was not applicable for this collection.",
                example: '0',
              },
              negative_effectiveness: {
                type: 'string',
                enum: %w[0 1],
                description: 'Whether the respondent cited effectiveness as a negative factor.',
                example: '0',
              },
              negative_ease: {
                type: 'string',
                enum: %w[0 1],
                description: 'Whether the respondent cited ease as a negative factor.',
                example: '0',
              },
              negative_efficiency: {
                type: 'string',
                enum: %w[0 1],
                description: 'Whether the respondent cited efficiency as a negative factor.',
                example: '0',
              },
              negative_transparency: {
                type: 'string',
                enum: %w[0 1],
                description: 'Whether the respondent cited transparency as a negative factor.',
                example: '0',
              },
              negative_humanity: {
                type: 'string',
                enum: %w[0 1 null],
                description: "Whether the respondent cited humanity as a negative factor. 'null' (string) indicates the dimension was not applicable for this collection.",
                example: 'null',
              },
              negative_employee: {
                type: 'string',
                enum: %w[0 1 null],
                description: "Whether the respondent cited employee as a negative factor. 'null' (string) indicates the dimension was not applicable for this collection.",
                example: 'null',
              },
              negative_other: {
                type: 'string',
                enum: %w[0 1 null],
                description: "Whether the respondent cited other as a negative factor. 'null' (string) indicates the dimension was not applicable for this collection.",
                example: 'null',
              },
              question_4: {
                type: 'string',
                nullable: true,
                description: 'Open-text response to question 4. Null if not answered.',
                example: 'Text',
              },
              job_id: {
                type: 'string',
                description: 'Identifier of the batch import job that created this response.',
                example: 'd61af450e8',
              },
              created_at: {
                type: 'string',
                format: 'date-time',
                description: 'ISO 8601 timestamp when the response was created.',
                example: '2024-10-07T14:47:14.260Z',
              },
              updated_at: {
                type: 'string',
                format: 'date-time',
                description: 'ISO 8601 timestamp when the response was last updated.',
                example: '2024-10-07T14:47:14.260Z',
              },
              external_id: {
                type: 'string',
                description: 'Identifier of this response in the originating external system.',
              },
            },
          },

          FormResource: {
            type: 'object',
            description: 'A survey form',
            required: %w[id type attributes relationships],
            properties: {
              id: {
                type: 'string',
                description: 'Numeric identifier of the form (string-encoded).',
                example: '86',
              },
              type: {
                type: 'string',
                enum: ['forms'],
                example: 'forms',
              },
              attributes: {
                '$ref': '#/components/schemas/FormAttributes',
              },
              relationships: {
                '$ref': '#/components/schemas/FormRelationships',
              },
            },
          },

          FormAttributes: {
            type: 'object',
            required: %w[name title kind aasm_state delivery_method uuid short_uuid organization_id user_id audience header_logo_display success_text_heading success_text modal_button_text early_submission template load_css survey_form_activations response_count logo time_zone tag_list created_at updated_at],
            properties: {
              name: {
                type: 'string',
                description: 'Internal name of the form.',
                example: 'touchpoints.digital.gov Open-ended Feedback Form',
              },
              title: {
                type: 'string',
                description: 'Public-facing title displayed to respondents.',
                example: 'Product feedback form',
              },
              instructions: {
                type: 'string',
                nullable: true,
                description: 'HTML instructions displayed above the form. May be empty string or null.',
              },
              disclaimer_text: {
                type: 'string',
                nullable: true,
                description: 'HTML disclaimer text displayed on the form. May be empty string or null.',
              },
              kind: {
                type: 'string',
                enum: %w[a11_v2 custom open_ended],
                description: 'Form template type.',
                example: 'open_ended',
              },
              notes: {
                type: 'string',
                nullable: true,
                description: 'Internal notes about the form. May be empty string or null.',
              },
              status: {
                type: 'string',
                nullable: true,
                description: 'Optional status label. Null if not set.',
              },
              created_at: {
                type: 'string',
                format: 'date-time',
                description: 'ISO 8601 timestamp when the form was created.',
                example: '2020-02-18T23:29:19.845Z',
              },
              updated_at: {
                type: 'string',
                format: 'date-time',
                description: 'ISO 8601 timestamp when the form was last updated.',
                example: '2026-06-15T00:19:00.761Z',
              },
              whitelist_url: {
                type: 'string',
                description: 'Primary URL allowed to embed this form. May be empty string.',
                example: 'https://touchpoints.digital.gov/',
              },
              whitelist_url_1: {
                type: 'string',
                nullable: true,
                description: 'Additional allowed embed URL slot 1. Null or empty string if unused.',
              },
              whitelist_url_2: {
                type: 'string',
                nullable: true,
                description: 'Additional allowed embed URL slot 2. Null or empty string if unused.',
              },
              whitelist_url_3: {
                type: 'string',
                nullable: true,
                description: 'Additional allowed embed URL slot 3. Null or empty string if unused.',
              },
              whitelist_url_4: {
                type: 'string',
                nullable: true,
                description: 'Additional allowed embed URL slot 4. Null or empty string if unused.',
              },
              whitelist_url_5: {
                type: 'string',
                nullable: true,
                description: 'Additional allowed embed URL slot 5. Null or empty string if unused.',
              },
              whitelist_url_6: {
                type: 'string',
                nullable: true,
                description: 'Additional allowed embed URL slot 6. Null or empty string if unused.',
              },
              whitelist_url_7: {
                type: 'string',
                nullable: true,
                description: 'Additional allowed embed URL slot 7. Null or empty string if unused.',
              },
              whitelist_url_8: {
                type: 'string',
                nullable: true,
                description: 'Additional allowed embed URL slot 8. Null or empty string if unused.',
              },
              whitelist_url_9: {
                type: 'string',
                nullable: true,
                description: 'Additional allowed embed URL slot 9. Null or empty string if unused.',
              },
              whitelist_test_url: {
                type: 'string',
                description: 'Test URL allowed to embed this form. May be empty string.',
              },
              header_logo_display: {
                type: 'string',
                enum: %w[banner square],
                description: 'Display style for the header logo.',
                example: 'banner',
              },
              success_text_heading: {
                type: 'string',
                description: 'Heading shown on the success confirmation screen.',
                example: 'Success',
              },
              success_text: {
                type: 'string',
                description: 'HTML body text shown on the success confirmation screen.',
                example: 'Thank you. We appreciate your feedback, and will consider it as we evolve our services.',
              },
              modal_button_text: {
                type: 'string',
                description: 'Label text for the button that opens the form modal.',
                example: 'How can we improve Touchpoints?',
              },
              early_submission: {
                type: 'boolean',
                description: 'Whether the form supports early/partial submission.',
                example: false,
              },
              template: {
                type: 'boolean',
                description: 'Whether this form is a reusable template.',
                example: false,
              },
              uuid: {
                type: 'string',
                format: 'uuid',
                description: 'Full UUID identifier for the form.',
                example: '92b47c29-62d9-431b-b9d0-6312864349ec',
              },
              short_uuid: {
                type: 'string',
                description: 'First 8 characters of the UUID, used in short URLs.',
                example: '92b47c29',
              },
              organization_id: {
                type: 'integer',
                description: 'ID of the organization that owns the form.',
                example: 1,
              },
              audience: {
                type: 'string',
                enum: ['public'],
                description: 'Intended audience for the form.',
                example: 'public',
              },
              omb_approval_number: {
                type: 'string',
                description: 'OMB PRA approval number. May be empty string if not yet approved.',
                example: '1234-5678',
              },
              expiration_date: {
                type: 'string',
                format: 'date',
                nullable: true,
                description: 'ISO 8601 date on which the form or OMB approval expires.',
              },
              medium: {
                type: 'string',
                nullable: true,
                description: 'Distribution medium for the form. May be empty string or null.',
              },
              federal_register_url: {
                type: 'string',
                nullable: true,
                description: 'URL of the Federal Register notice for this form. May be empty string or null.',
              },
              anticipated_delivery_count: {
                type: 'integer',
                nullable: true,
                description: 'Estimated number of responses expected. Null if not specified.',
              },
              service_name: {
                type: 'string',
                nullable: true,
                description: 'Name of the associated service. May be empty string or null.',
              },
              data_submission_comment: {
                type: 'string',
                nullable: true,
                description: 'Comment added at data submission time. Null if not provided.',
              },
              survey_instrument_reference: {
                type: 'string',
                nullable: true,
                description: 'Reference to the original survey instrument. May be empty string or null.',
              },
              agency_poc_email: {
                type: 'string',
                nullable: true,
                description: 'Email address of the agency point of contact. May be empty string or null.',
                example: 'john.smith@gsa.gov',
              },
              agency_poc_name: {
                type: 'string',
                nullable: true,
                description: 'Name of the agency point of contact. May be empty string or null.',
                example: 'John Smith',
              },
              department: {
                type: 'string',
                nullable: true,
                description: 'Department associated with the form. May be empty string or null.',
                example: 'TTS',
              },
              bureau: {
                type: 'string',
                nullable: true,
                description: 'Bureau associated with the form. May be empty string or null.',
                example: '',
              },
              notification_emails: {
                type: 'string',
                nullable: true,
                description: 'Comma-separated list of email addresses to notify on submission. May be empty string or null.',
                example: 'john.smith@gsa.gov,jane.smith@gsa.gov',
              },
              start_date: {
                type: 'string',
                format: 'date-time',
                nullable: true,
                description: 'ISO 8601 datetime when the form becomes active. Null if always active.',
              },
              end_date: {
                type: 'string',
                format: 'date-time',
                nullable: true,
                description: 'ISO 8601 datetime when the form closes. Null if no end date.',
              },
              aasm_state: {
                type: 'string',
                enum: %w[archived created published],
                description: 'Current workflow state of the form.',
                example: 'published',
              },
              delivery_method: {
                type: 'string',
                enum: %w[inline modal touchpoints-hosted-only],
                description: 'How the form is delivered to respondents.',
                example: 'modal',
              },
              element_selector: {
                type: 'string',
                description: 'CSS selector or element ID used to attach the form. May be empty string.',
                example: 'button-goes-here',
                nullable: true,
              },
              survey_form_activations: {
                type: 'integer',
                description: 'Number of times the form has been activated or displayed.',
                example: 279_562,
              },
              load_css: {
                type: 'boolean',
                description: 'Whether the form loads its own CSS stylesheet.',
                example: true,
              },
              logo: {
                '$ref': '#/components/schemas/Logo',
              },
              time_zone: {
                type: 'string',
                description: 'Time zone used for form timestamps (Rails time zone name).',
                example: 'Eastern Time (US & Canada)',
              },
              response_count: {
                type: 'integer',
                description: 'Total number of responses submitted to this form.',
                example: 2122,
              },
              last_response_created_at: {
                type: 'string',
                format: 'date-time',
                nullable: true,
                description: 'ISO 8601 timestamp of the most recent submission. Null if no responses yet.',
                example: '2026-06-15T00:19:00.739Z',
              },
              tag_list: {
                type: 'array',
                description: 'List of tag labels applied to this form.',
                items: {
                  type: 'string',
                },
                example: %w[touchpoints cx],
              },
            },
          },

          FormRelationships: {
            type: 'object',
            required: %w[questions service],
            properties: {
              questions: {
                type: 'object',
                required: ['data'],
                properties: {
                  data: {
                    type: 'array',
                    items: {
                      '$ref': '#/components/schemas/FormQuestion',
                    },
                  },
                },
              },
              service: {
                type: 'object',
                required: ['data'],
                properties: {
                  data: {
                    type: 'object',
                    nullable: true,
                    description: 'Reference to the associated service, or null if unlinked.',
                    required: %w[id type],
                    properties: {
                      id: {
                        type: 'string',
                        description: 'Numeric identifier of the Service (string-encoded).',
                      },
                      type: {
                        type: 'string',
                        enum: ['services'],
                        example: 'services',
                      },
                    },
                  },
                },
              },
            },
          },

          FormQuestion: {
            type: 'object',
            required: %w[id form_id text question_type answer_field position form_section_id created_at updated_at],
            properties: {
              id: {
                type: 'integer',
                description: 'Numeric identifier of the question.',
                example: 416,
              },
              form_id: {
                type: 'integer',
                description: 'ID of the form this question belongs to.',
                example: 86,
              },
              text: {
                type: 'string',
                description: 'Question text displayed to the respondent. May contain HTML. May be empty string.',
                example: 'Email',
              },
              question_type: {
                type: 'string',
                enum: %w[big_thumbs_up_down_buttons checkbox combobox custom_text_display date_select dropdown radio_buttons rich_textarea states_dropdown text_display text_email_field text_field text_phone_field textarea yes_no_buttons],
                description: "The UI control type used to render and capture this question's answer.",
                example: 'text_email_field',
              },
              answer_field: {
                type: 'string',
                pattern: '^answer_[0-9]{2}$',
                description: "Slot identifier for storing this question's response (e.g. 'answer_01').",
                example: 'answer_02',
              },
              position: {
                type: 'integer',
                description: 'Display order of the question within its form section.',
                example: 2,
              },
              is_required: {
                type: 'boolean',
                nullable: true,
                description: 'Whether a response to this question is required for form submission. Null if not explicitly set.',
                example: true,
              },
              form_section_id: {
                type: 'integer',
                description: 'ID of the form section this question belongs to.',
                example: 141,
              },
              character_limit: {
                type: 'integer',
                nullable: true,
                description: 'Maximum number of characters allowed in the response. Null if no limit.',
                example: 2500,
              },
              placeholder_text: {
                type: 'string',
                nullable: true,
                description: 'Placeholder text shown inside the input. May be empty string or null.',
                example: 'feedback@example.gov',
              },
              help_text: {
                type: 'string',
                nullable: true,
                description: 'Additional guidance shown alongside the question. May be empty string or null.',
                example: 'If so, please explain.',
              },
              created_at: {
                type: 'string',
                format: 'date-time',
                description: 'ISO 8601 timestamp when the question was created.',
                example: '2020-02-18T23:29:19.913Z',
              },
              updated_at: {
                type: 'string',
                format: 'date-time',
                description: 'ISO 8601 timestamp when the question was last updated.',
                example: '2025-04-08T16:38:56.500Z',
              },
            },
          },
          
          Logo: {
            type: 'object',
            required: %w[url thumb card tag logo_square],
            properties: {
              url: {
                type: 'string',
                format: 'uri',
                nullable: true,
                description: 'Full-size logo image URL.',
              },
              thumb: {
                '$ref': '#/components/schemas/LogoVariant',
                description: 'Thumbnail-sized logo variant.',
              },
              card: {
                '$ref': '#/components/schemas/LogoVariant',
                description: 'Card-sized logo variant.',
              },
              tag: {
                '$ref': '#/components/schemas/LogoVariant',
                description: 'Tag-sized logo variant.',
              },
              logo_square: {
                '$ref': '#/components/schemas/LogoVariant',
                description: 'Square-cropped logo variant.',
              },
            },
          },

          LogoVariant: {
            type: 'object',
            required: ['url'],
            properties: {
              url: {
                type: 'string',
                format: 'uri',
                nullable: true,
                description: 'URL for this logo size variant. Null if no logo has been uploaded.',
              },
            },
          },

          SubmissionResource: {
            type: 'object',
            description: "A submitted response to a form, representing a single respondent's answers to the survey questions.",
            required: %w[id type attributes],
            properties: {
              id: {
                type: 'string',
                description: 'Numeric identifier of the submission (string-encoded).',
                example: '5171',
              },
              type: {
                type: 'string',
                enum: ['submissions'],
                example: 'submissions',
              },
              attributes: {
                '$ref': '#/components/schemas/SubmissionAttributes',
              },
            },
          },

          SubmissionAttributes: {
            type: 'object',
            required: %w[page flagged archived deleted aasm_state language uuid tags created_at updated_at answer_01 answer_02 answer_03 answer_04 answer_05 answer_06 answer_07 answer_08 answer_09 answer_10 answer_11 answer_12 answer_13 answer_14 answer_15 answer_16 answer_17 answer_18 answer_19 answer_20 answer_21 answer_22 answer_23 answer_24 answer_25 answer_26 answer_27 answer_28 answer_29 answer_30],
            properties: {
              user_id: {
                type: 'integer',
                nullable: true,
                description: 'ID of the authenticated user who submitted, if any. Null for anonymous submissions.',
              },
              created_at: {
                type: 'string',
                format: 'date-time',
                description: 'ISO 8601 timestamp when the submission was received.',
                example: '2020-07-15T18:53:01.352Z',
              },
              updated_at: {
                type: 'string',
                format: 'date-time',
                description: 'ISO 8601 timestamp when the submission was last updated.',
                example: '2025-02-25T17:37:06.114Z',
              },
              referer: {
                type: 'string',
                description: 'HTTP Referer header value at time of submission. May be empty string.',
                example: 'https://feedback.usa.gov/about/',
              },
              hostname: {
                type: 'string',
                nullable: true,
                description: 'Hostname of the page that hosted the form at submission time. Null for older submissions.',
                example: 'touchpoints.digital.gov',
              },
              page: {
                type: 'string',
                description: 'Path of the page that hosted the form at submission time.',
                example: '/',
              },
              query_string: {
                type: 'string',
                nullable: true,
                description: 'URL query string present at submission time. Null for older submissions.',
              },
              user_agent: {
                type: 'string',
                description: "HTTP User-Agent string of the respondent's browser.",
                example: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36',
              },
              answer_01: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 01.',
                example: 'John',
              },
              answer_02: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 02.',
                example: 'john@example.com',
              },
              answer_03: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 03.',
                example: 'The buttons on the bottom of your website fail WCAG 2.0 contrast requirements.',
              },
              answer_04: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 04.',
              },
              answer_05: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 05.',
              },
              answer_06: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 06.',
              },
              answer_07: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 07.',
              },
              answer_08: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 08.',
              },
              answer_09: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 09.',
              },
              answer_10: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 10.',
              },
              answer_11: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 11.',
              },
              answer_12: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 12.',
              },
              answer_13: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 13.',
              },
              answer_14: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 14.',
              },
              answer_15: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 15.',
              },
              answer_16: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 16.',
              },
              answer_17: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 17.',
              },
              answer_18: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 18.',
              },
              answer_19: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 19.',
              },
              answer_20: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 20.',
              },
              answer_21: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 21.',
              },
              answer_22: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 22.',
              },
              answer_23: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 23.',
              },
              answer_24: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 24.',
              },
              answer_25: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 25.',
              },
              answer_26: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 26.',
              },
              answer_27: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 27.',
              },
              answer_28: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 28.',
              },
              answer_29: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 29.',
              },
              answer_30: {
                type: 'string',
                nullable: true,
                description: 'Response to question slot 30.',
              },
              ip_address: {
                type: 'string',
                description: 'IPv4 or IPv6 address of the respondent at submission time.',
              },
              location_code: {
                type: 'string',
                description: 'Geographic location code associated with the submission. May be empty string.',
              },
              flagged: {
                type: 'boolean',
                description: 'Whether this submission has been flagged for review.',
              },
              archived: {
                type: 'boolean',
                description: 'Whether this submission has been archived.',
              },
              deleted: {
                type: 'boolean',
                description: 'Whether this submission has been soft-deleted.',
                example: false,
              },
              deleted_at: {
                type: 'string',
                format: 'date-time',
                nullable: true,
                description: 'ISO 8601 timestamp when the submission was soft-deleted. Null if not deleted.',
              },
              aasm_state: {
                type: 'string',
                enum: %w[acknowledged received responded],
                description: 'Current workflow state of the submission.',
                example: 'received',
              },
              language: {
                type: 'string',
                description: "BCP 47 language tag of the respondent's browser locale.",
                example: 'en',
              },
              uuid: {
                type: 'string',
                format: 'uuid',
                description: 'Unique identifier for this submission.',
                example: '0db041a9-4c2f-4fa9-a062-db3f91b6f79c',
              },
              tags: {
                type: 'array',
                description: 'Tags applied to this submission.',
                items: {
                  type: 'string',
                },
                example: ['feature-request'],
              },
            },
          },

          ServiceProviderResource: {
            type: 'object',
            description: 'Represents a service provider organization, which may have one or more services associated with it.',
            required: %w[id type attributes],
            properties: {
              id: {
                type: 'string',
                description: 'Numeric identifier of the service provider (string-encoded).',
                example: '2',
              },
              type: {
                type: 'string',
                enum: ['service_providers'],
                example: 'service_providers',
              },
              attributes: {
                '$ref': '#/components/schemas/ServiceProviderAttributes',
              },
            },
          },

          ServiceProviderAttributes: {
            type: 'object',
            required: %w[organization_id organization_abbreviation organization_name name slug year_designated description department department_abbreviation bureau inactive new portfolio_manager_email service_provider_managers services_count],
            properties: {
              organization_id: {
                type: 'integer',
                description: 'Numeric ID of the parent organization.',
                example: 2098,
              },
              organization_abbreviation: {
                type: 'string',
                description: 'Short acronym of the parent organization.',
                example: 'USDA',
              },
              organization_name: {
                type: 'string',
                description: 'Full name of the parent organization.',
                example: 'Department of Agriculture',
              },
              name: {
                type: 'string',
                description: 'Display name of the service provider.',
                example: 'Natural Resources Conservation Service',
              },
              slug: {
                type: 'string',
                description: 'URL-safe identifier for the service provider.',
                example: 'usda-nrcs',
              },
              year_designated: {
                type: 'integer',
                description: 'Year the service provider was officially designated.',
                example: 2018,
              },
              description: {
                type: 'string',
                description: "Long-form description of the service provider's mission and scope.",
                example: 'NRCS works with farmers...',
              },
              notes: {
                type: 'string',
                description: 'Optional freeform notes. May be empty string.',
                example: '',
              },
              department: {
                type: 'string',
                description: "Lowercase department code or label (e.g. 'usda', 'Multi-Agency').",
                example: 'usda',
              },
              department_abbreviation: {
                type: 'string',
                description: 'Lowercase department acronym.',
                example: 'usda',
              },
              bureau: {
                type: 'string',
                description: 'Name of the bureau within the department.',
                example: 'Natural Resources Conservation Service',
              },
              inactive: {
                type: 'boolean',
                description: 'Whether the service provider is inactive.',
                example: false,
              },
              url: {
                type: 'string',
                format: 'uri',
                nullable: true,
                description: 'Public URL for the service provider. Null if not yet assigned.',
              },
              new: {
                type: 'boolean',
                description: 'Whether the service provider was recently added.',
                example: false,
              },
              portfolio_manager_email: {
                type: 'string',
                format: 'email',
                description: 'Email address of the OMB portfolio manager responsible for this provider.',
                example: 'jane.smith@usda.gov',
              },
              service_provider_managers: {
                type: 'array',
                description: 'List of agency-side managers for this service provider.',
                items: {
                  '$ref': '#/components/schemas/User',
                },
              },
              services_count: {
                type: 'integer',
                description: 'Number of services associated with this provider.',
                example: 1,
              },
            },
          },

          ServiceResource: {
            type: 'object',
            description: 'A service record representing a discrete public-facing service offered by a federal agency.',
            required: %w[id type attributes],
            properties: {
              id: {
                type: 'string',
                description: 'Numeric identifier of the service (string-encoded).',
                example: '1',
              },
              type: {
                type: 'string',
                enum: ['services'],
                example: 'services',
              },
              attributes: {
                '$ref': '#/components/schemas/ServiceAttributes',
              },
            },
          },

          ServiceAttributes: {
            type: 'object',
            required: %w[name description organization_id organization_abbreviation organization_name previously_reported contact_center kind transactional hisp service_owner_email service_managers channels tags available_in_person available_digitally available_via_phone aasm_state],
            properties: {
              name: {
                type: 'string',
                description: 'Display name of the service.',
                example: 'Touchpoints',
              },
              description: {
                type: 'string',
                description: 'Long-form description of the service.',
                example: 'Making customer feedback easier for federal agencies.',
              },
              organization_id: {
                type: 'integer',
                description: 'Numeric ID of the parent organization.',
                example: 1,
              },
              organization_abbreviation: {
                type: 'string',
                description: 'Short acronym of the parent organization.',
                example: 'GSA',
              },
              organization_name: {
                type: 'string',
                description: 'Full name of the parent organization.',
                example: 'General Services Administration',
              },
              service_provider_id: {
                type: 'integer',
                nullable: true,
                description: 'Numeric ID of the associated service provider. Null if unassigned.',
                example: 44,
              },
              service_provider_name: {
                type: 'string',
                nullable: true,
                description: 'Display name of the associated service provider. Null if unassigned.',
                example: 'Non-HISP Service Provider',
              },
              service_provider_slug: {
                type: 'string',
                nullable: true,
                description: 'URL-safe slug of the associated service provider. Null if unassigned.',
                example: 'non-hisp',
              },
              short_description: {
                type: 'string',
                description: 'Brief summary of the service. May be empty string.',
                example: '',
              },
              year_designated: {
                type: 'integer',
                nullable: true,
                description: 'Year the service was officially designated. Null if not yet designated.',
                example: 2021,
              },
              previously_reported: {
                type: 'boolean',
                description: 'Whether this service was reported in a prior reporting period.',
                example: false,
              },
              contact_center: {
                type: 'boolean',
                description: 'Whether the service operates a contact center.',
                example: false,
              },
              kind: {
                type: 'array',
                description: 'One or more service type classifications.',
                items: {
                  type: 'string',
                  enum: [
                    'Administrative',
                    'Benefits',
                    'Data and Research',
                    'Informational',
                    'Other',
                  ],
                },
                example: ['Data and Research'],
              },
              transactional: {
                type: 'boolean',
                description: 'Whether the service is transactional in nature.',
                example: false,
              },
              notes: {
                type: 'string',
                description: 'Internal freeform notes about the service. May be empty string.',
                example: 'John Smith as System Owner, Product Manager',
              },
              hisp: {
                type: 'boolean',
                description: 'Whether the service is a High Impact Service Provider (HISP) service.',
                example: false,
              },
              service_slug: {
                type: 'string',
                description: 'URL-safe slug for the service. May be empty string.',
                example: 'usda-fsa',
              },
              service_owner_email: {
                type: 'string',
                format: 'email',
                description: 'Email address of the service owner.',
                example: 'john.smith@gsa.gov',
              },
              service_managers: {
                type: 'array',
                description: 'List of managers responsible for this service.',
                items: {
                  '$ref': '#/components/schemas/User',
                },
              },
              url: {
                type: 'string',
                format: 'uri',
                description: 'Direct URL to the service. May be empty string.',
                example: 'https://touchpoints.digital.gov/',
              },
              homepage_url: {
                type: 'string',
                format: 'uri',
                description: 'Homepage URL for the service. May be empty string.',
                example: 'https://touchpoints.digital.gov/',
              },
              channels: {
                type: 'array',
                description: 'Delivery channels through which the service is available.',
                items: {
                  '$ref': '#/components/schemas/ServiceChannel',
                },
              },
              tags: {
                type: 'array',
                description: 'Taxonomy tags associated with the service.',
                items: {
                  '$ref': '#/components/schemas/Tag',
                },
              },
              available_in_person: {
                type: 'boolean',
                description: 'Whether the service is available in person.',
                example: false,
              },
              available_digitally: {
                type: 'boolean',
                description: 'Whether the service is available digitally.',
                example: true,
              },
              available_via_phone: {
                type: 'boolean',
                description: 'Whether the service is available via phone.',
                example: true,
              },
              aasm_state: {
                type: 'string',
                description: 'Current workflow state of the service record.',
                enum: %w[created verified],
                example: 'verified',
              },
            },
          },

          ServiceChannel: {
            type: 'object',
            required: %w[id name created_at updated_at taggings_count],
            properties: {
              id: {
                type: 'integer',
                description: 'Numeric identifier of the channel tag.',
                example: 315,
              },
              name: {
                type: 'string',
                description: "Machine-readable channel name (e.g. 'email', 'phone', 'computer', 'other_digital').",
                example: 'email',
              },
              created_at: {
                type: 'string',
                format: 'date-time',
                description: 'ISO 8601 timestamp when the channel tag was created.',
                example: '2022-08-16T21:50:46.381Z',
              },
              updated_at: {
                type: 'string',
                format: 'date-time',
                description: 'ISO 8601 timestamp when the channel tag was last updated.',
                example: '2022-08-16T21:50:46.381Z',
              },
              taggings_count: {
                type: 'integer',
                description: 'Number of times this channel tag has been applied across all services.',
                example: 2,
              },
            },
          },

          WebsiteResource: {
            type: 'object',
            required: %w[id type attributes],
            properties: {
              id: {
                type: 'string',
                description: 'Numeric identifier of the website (string-encoded).',
                example: '706',
              },
              type: {
                type: 'string',
                enum: ['websites'],
                example: 'websites',
              },
              attributes: {
                '$ref': '#/components/schemas/WebsiteAttributes',
              },
            },
          },

          WebsiteAttributes: {
            type: 'object',
            required: %w[domain organization_id organization_name parent_domain login_supported website_contacts created_at updated_at],
            properties: {
              domain: {
                type: 'string',
                description: 'Fully qualified domain name of the website.',
                example: 'touchpoints.app.cloud.gov',
              },
              organization_id: {
                type: 'integer',
                description: 'ID of the organization that owns the website.',
                example: 1,
              },
              organization_name: {
                type: 'string',
                description: 'Display name of the organization that owns the website.',
                example: 'General Services Administration',
              },
              parent_domain: {
                type: 'string',
                description: 'Parent domain under which this website resides.',
                example: 'cloud.gov',
              },
              office: {
                type: 'string',
                nullable: true,
                description: 'Office within the organization responsible for the website. May be empty string or null.',
                example: 'FAS',
              },
              sub_office: {
                type: 'string',
                nullable: true,
                description: 'Sub-office within the office responsible for the website. May be empty string or null.',
                example: 'TTS',
              },
              contact_email: {
                type: 'string',
                format: 'email',
                nullable: true,
                description: 'General contact email for the website. May be empty string or null.',
                example: 'feedback-analytics@gsa.gov',
              },
              site_owner_email: {
                type: 'string',
                format: 'email',
                nullable: true,
                description: 'Email address of the site owner. May be empty string or null.',
                example: 'john.smith@gsa.gov',
              },
              production_status: {
                type: 'string',
                enum: [
                  'decommissioned',
                  'in_development',
                  'production',
                  'redirect',
                  'staging'
                ],
                description: 'Current lifecycle status of the website.',
                example: 'production',
              },
              type_of_site: {
                type: 'string',
                nullable: true,
                description: "Categorization of the site's primary purpose (e.g. 'Informational', 'Application', 'API', 'Critical infrastructure'). May be null.",
                example: 'Application',
              },
              digital_brand_category: {
                type: 'string',
                nullable: true,
                description: "Digital brand classification (e.g. 'GSA Business', 'Hybrid', 'External'). May be empty string or null.",
                example: 'GSA Business',
              },
              redirects_to: {
                type: 'string',
                nullable: true,
                description: 'URL or domain this site redirects to. Null or empty string if not a redirect.',
                example: 'https://www.usa.gov/',
              },
              status_code: {
                type: 'string',
                nullable: true,
                description: 'Last observed HTTP status code. May be null if not yet checked.',
                example: '200',
              },
              cms_platform: {
                type: 'string',
                nullable: true,
                description: "CMS or hosting platform used to build the site (e.g. 'Federalist', 'Netlify'). May be empty string or null.",
                example: 'n/a',
              },
              required_by_law_or_policy: {
                type: 'string',
                nullable: true,
                description: "Applicable law or policy mandate (e.g. 'A-11, Section 280'). May be empty string or null.",
                example: 'A-11, Section 280',
              },
              has_dap: {
                type: 'boolean',
                nullable: true,
                description: 'Whether the Digital Analytics Program (DAP) is implemented on the site. Null if unknown.',
                example: true,
              },
              dap_gtm_code: {
                type: 'string',
                nullable: true,
                description: 'DAP Google Tag Manager code. May be empty string or null.',
                example: 'Yes',
              },
              analytics_url: {
                type: 'string',
                nullable: true,
                description: "URL to the site's public analytics dashboard. May be empty string or null.",
                example: '',
              },
              uses_feedback: {
                type: 'boolean',
                nullable: true,
                description: 'Whether the site uses a feedback collection tool. Null if unknown.',
                example: false,
              },
              feedback_tool: {
                type: 'string',
                nullable: true,
                description: "Name of the feedback tool in use (e.g. 'Touchpoints', 'Medallia', 'None'). May be null.",
                example: 'Touchpoints',
              },
              sitemap_url: {
                type: 'string',
                nullable: true,
                description: "URL of the site's XML sitemap. May be empty string or null.",
                example: 'https://10x.gsa.gov/sitemap.xml',
              },
              backlog_tool: {
                type: 'string',
                description: "Name of the project backlog tool in use (e.g. 'Trello', 'GitHub', 'Jira', 'None'). May be empty string.",
                example: 'Trello',
              },
              backlog_url: {
                type: 'string',
                description: 'URL to the project backlog. May be empty string.',
                example: '',
              },
              mobile_friendly: {
                type: 'boolean',
                nullable: true,
                description: 'Whether the site is mobile-friendly. Null if unknown.',
                example: true,
              },
              has_search: {
                type: 'boolean',
                nullable: true,
                description: 'Whether the site has a search feature. Null if unknown.',
                example: false,
              },
              uses_tracking_cookies: {
                type: 'boolean',
                nullable: true,
                description: 'Whether the site uses tracking cookies. Null if unknown.',
                example: false,
              },
              has_authenticated_experience: {
                type: 'boolean',
                nullable: true,
                description: 'Whether the site has an authenticated user experience. Null if unknown.',
                example: false,
              },
              authentication_tool: {
                type: 'string',
                nullable: true,
                description: "Authentication platform used (e.g. 'Login.gov', 'Okta', 'Max.gov', 'None'). May be null.",
                example: 'Login.gov',
              },
              login_supported: {
                type: 'boolean',
                description: 'Whether user login is supported on the site.',
                example: true,
              },
              notes: {
                type: 'string',
                nullable: true,
                description: 'Internal freeform notes about the website. May be empty string or null.',
                example: '',
              },
              repository_url: {
                type: 'string',
                format: 'uri',
                nullable: true,
                description: 'URL of the source code repository. May be empty string or null.',
                example: 'https://github.com/gsa/touchpoints',
              },
              hosting_platform: {
                type: 'string',
                nullable: true,
                description: "Infrastructure hosting platform (e.g. 'Cloud.gov', 'Federalist'). May be empty string or null.",
                example: 'cloud.gov',
              },
              website_contacts: {
                type: 'array',
                description: 'List of contacts associated with this website.',
                items: {
                  '$ref': '#/components/schemas/User',
                },
              },
              uswds_version: {
                type: 'string',
                nullable: true,
                description: 'Version of the U.S. Web Design System in use. May be empty string or null.',
                example: '3.1',
              },
              https: {
                type: 'boolean',
                nullable: true,
                description: 'Whether the site enforces HTTPS. Null if unknown.',
                example: true,
              },
              target_decommission_date: {
                type: 'string',
                format: 'date',
                nullable: true,
                description: 'ISO 8601 date on which the site is planned to be decommissioned. Null if not scheduled.',
              },
              created_at: {
                type: 'string',
                format: 'date-time',
                description: 'ISO 8601 timestamp when the record was created.',
                example: '2023-12-13T19:47:40.729Z',
              },
              updated_at: {
                type: 'string',
                format: 'date-time',
                description: 'ISO 8601 timestamp when the record was last updated.',
                example: '2026-03-04T22:20:26.380Z',
              },
            },
          },

          DigitalProductResource: {
            type: 'object',
            required: %w[id type attributes],
            properties: {
              id: {
                type: 'string',
                description: 'Numeric identifier of the digital product (string-encoded).',
                example: '36',
              },
              type: {
                type: 'string',
                enum: ['digital_products'],
                example: 'digital_products',
              },
              attributes: {
                '$ref': '#/components/schemas/DigitalProductAttributes',
              },
            },
          },

          DigitalProductAttributes: {
            type: 'object',
            description: 'Attributes of a digital product.',
            required: %w[agencies contacts language status short_description long_description tags],
            properties: {
              agencies: {
                type: 'array',
                description: 'Organizations associated with this digital product.',
                items: {
                  '$ref': '#/components/schemas/DigitalProductAgency',
                },
              },
              contacts: {
                type: 'array',
                description: 'Contacts responsible for this digital product.',
                items: {
                  '$ref': '#/components/schemas/DigitalProductContact',
                },
              },
              service: {
                type: 'object',
                nullable: true,
                description: 'Associated service record. Null if not linked.',
              },
              url: {
                type: 'string',
                format: 'uri',
                nullable: true,
                description: 'Public URL of the digital product. Null if not yet assigned.',
              },
              code_repository_url: {
                type: 'string',
                format: 'uri',
                nullable: true,
                description: 'URL of the source code repository. Null if not provided.',
              },
              language: {
                type: 'string',
                description: 'Primary language of the digital product.',
                example: 'English',
              },
              status: {
                type: 'string',
                enum: ['published'],
                description: 'Publication status of the digital product.',
                example: 'published',
              },
              short_description: {
                type: 'string',
                description: 'Brief summary of the digital product.',
                example: 'Practice sun safety; check the UV Index and air quality ratings wherever you are.',
              },
              long_description: {
                type: 'string',
                description: 'Full HTML description of the digital product.',
                example: '<p>Use your mobile device to check the UV Index and air quality ratings wherever you are.</p>',
              },
              tags: {
                type: 'array',
                description: 'Tags applied to this digital product.',
                items: {
                  type: 'string',
                },
              },
              certified_at: {
                type: 'string',
                format: 'date-time',
                nullable: true,
                description: 'ISO 8601 timestamp when the product was certified. Null if not yet certified.',
              },
            },
          },


          User: {
            type: 'object',
            description: 'A Touchpoints user account.',
            required: ['email'],
            properties: {
              email: {
                type: 'string',
                format: 'email',
                description: 'Work email of the user.',
                example: 'john.smith@gsa.gov',
              },
              first_name: {
                type: 'string',
                nullable: true,
                description: "User's first name. Null if not yet provided.",
                example: 'John',
              },
              last_name: {
                type: 'string',
                nullable: true,
                description: "User's last name. Null if not yet provided.",
                example: 'Smith',
              },
              position_title: {
                type: 'string',
                nullable: true,
                description: "User's job title. Null if not yet provided.",
                example: 'Innovation Specialist',
              },
              profile_photo: {
                type: 'string',
                format: 'uri',
                nullable: true,
                description: "URL to the user's profile photo. Null if not uploaded.",
              },
            },
          },

          Tag: {
            type: 'object',
            required: %w[id name created_at updated_at taggings_count],
            properties: {
              id: {
                type: 'integer',
                description: 'Numeric identifier of the tag.',
                example: 204,
              },
              name: {
                type: 'string',
                description: 'Human-readable tag label.',
                example: 'feedback',
              },
              created_at: {
                type: 'string',
                format: 'date-time',
                description: 'ISO 8601 timestamp when the tag was created.',
                example: '2022-06-07T13:15:45.585Z',
              },
              updated_at: {
                type: 'string',
                format: 'date-time',
                description: 'ISO 8601 timestamp when the tag was last updated.',
                example: '2022-06-07T13:15:45.585Z',
              },
              taggings_count: {
                type: 'integer',
                description: 'Number of times this tag has been applied',
                example: 12,
              },
            },
          },

          PaginationLinks: {
            type: 'object',
            required: %w[self first last],
            properties: {
              self: {
                type: 'string',
                format: 'uri',
                description: 'URL of the current page.',
              },
              first: {
                type: 'string',
                format: 'uri',
                description: 'URL of the first page.',
              },
              prev: {
                type: 'string',
                format: 'uri',
                nullable: true,
                description: 'URL of the previous page. Null on the first page.',
              },
              next: {
                type: 'string',
                format: 'uri',
                nullable: true,
                description: 'URL of the next page. Null on the last page.',
              },
              last: {
                type: 'string',
                format: 'uri',
                description: 'URL of the last page.',
              },
            },
          },

          ResponsePaginationLinks: {
            allOf: [
              { '$ref': '#/components/schemas/PaginationLinks' },
            ],
            description: 'Pagination links for a list of form responses.',
            example: {
              self: 'https://api.gsa.gov/analytics/touchpoints/v1/forms/8fc3c208/responses?page[number]=2&page[size]=500',
              first: 'https://api.gsa.gov/analytics/touchpoints/v1/forms/8fc3c208/responses?page[number]=1&page[size]=500',
              prev: 'https://api.gsa.gov/analytics/touchpoints/v1/forms/8fc3c208/responses?page[number]=1&page[size]=500',
              next: 'https://api.gsa.gov/analytics/touchpoints/v1/forms/8fc3c208/responses?page[number]=3&page[size]=500',
              last: 'https://api.gsa.gov/analytics/touchpoints/v1/forms/8fc3c208/responses?page[number]=8&page[size]=500',
            },
          },

          CxResponsePaginationLinks: {
            allOf: [
              { '$ref': '#/components/schemas/PaginationLinks' },
            ],
            description: 'Pagination links for a list of CX responses.',
            example: {
              self: 'https://api.gsa.gov/analytics/touchpoints/v1/cx_responses?page[number]=2&page[size]=500',
              first: 'https://api.gsa.gov/analytics/touchpoints/v1/cx_responses?page[number]=1&page[size]=500',
              prev: 'https://api.gsa.gov/analytics/touchpoints/v1/cx_responses?page[number]=1&page[size]=500',
              next: 'https://api.gsa.gov/analytics/touchpoints/v1/cx_responses?page[number]=3&page[size]=500',
              last: 'https://api.gsa.gov/analytics/touchpoints/v1/cx_responses?page[number]=8&page[size]=500',
            },
          },

          PaginationMeta: {
            type: 'object',
            required: %w[current_page page_size total_pages total_count],
            properties: {
              current_page: {
                type: 'integer',
                description: 'The current page number (1-indexed).',
                example: 1,
              },
              page_size: {
                type: 'integer',
                description: 'Number of records requested per page.',
                example: 500,
              },
              total_pages: {
                type: 'integer',
                description: 'Total number of pages available.',
                example: 8,
              },
              total_count: {
                type: 'integer',
                description: 'Total number of records across all pages.',
                example: 3_911,
              },
            },
          },

          DeprecatedPaginationLinks: {
            type: 'object',
            deprecated: true,
            description: 'An older style of pagination links, whose implementation was buggy.',
            required: %w[first last],
            properties: {
              first: {
                type: 'string',
                format: 'uri',
                description: 'URL of the first page.',
              },
              prev: {
                type: 'string',
                format: 'uri',
                nullable: true,
                description: 'URL of the previous page. Absent or null on the first page.',
              },
              next: {
                type: 'string',
                format: 'uri',
                nullable: true,
                description: 'URL of the next page. Absent or null on the last page.',
              },
              last: {
                type: 'string',
                format: 'uri',
                description: 'URL of the last page.',
              },
            },
          },
        },
      },
    },
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
