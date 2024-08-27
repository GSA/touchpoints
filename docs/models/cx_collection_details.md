### CX Collection Details

Each `CXCollection` has_many `CXCollectionDetail` records.

A `CXCollectionDetail` record belongs_to a `CXCollection` record.

| Field Name                                    | Format   | Description                                                                           | Sample Input                                                       |
|-----------------------------------------------|----------|---------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| channel                                       | string   | The channel through which the interaction occurred                                    | computer                                                           |
| created_at                                    | datetime | The timestamp when the record was created                                             | 2023-07-31 12:34:56                                                |
| cx_collection_id                              | integer  | Identifier for the CX Collection                                                      | 148                                                                |
| omb_control_number                            | string   | OMB control number for the survey                                                     | 0412-0609                                                          |
| service_id                                    | integer  | Identifier for the CX Collection's Service                                            | 132                                                                |
| service_name                                  | integer  | Name of the Service                                                                   | Passports                                                          |
| service_provider_id                           | integer  | Identifier for the Service Provider                                                   | 9722                                                               |
| service_provider_name                         | string   | Name of the Service Provider                                                          | Bureau of Consular Affairs                                         |
| service_stage_id                              | integer  | Identifier for the service stage                                                      | 317                                                                |
| service_stage_name                            | string   | Name of the Service Stage                                                             | end                                                                |
| survey_title                                  | string   | Title of the survey                                                                   | USAID Pre-Engagement Assessment Post Transaction Survey            |
| survey_type                                   | string   | Type of the survey                                                                    | thumbs up/down, likert scale                                       |
| trust_question_text                           | string   | Text of the question assessing trust                                                  | The assessment increased my trust in the USAID partnership process.|
| updated_at                                    | datetime | The timestamp when the record was last updated                                        | 2023-07-31 14:56:78                                                |
| volume_of_customers                           | integer  | The total volume of customers this quarter                                            | 3240                                                               |
| volume_of_customers_provided_survey_opportunity| integer  | The number of customers who were provided the opportunity to take the survey this quarter | 2324                                                          |
| volume_of_respondents                         | integer  | The number of respondents who completed the survey this quarter                       | 381448                                                             |