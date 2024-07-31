### CX Responses

The CX Response table holds details response records reported by HISP services each quarter.

| Field Name                         | Format   | Description                                                 | Sample Input                   |
|------------------------------------|----------|-------------------------------------------------------------|--------------------------------|
| created_at                         | datetime | The timestamp when the record was created                   | 2023-07-31 12:34:56            |
| cx_collection_detail_id            | integer  | Identifier for the CX Collection detail                     | 123                            |
| cx_collection_detail_upload_id     | integer  | Identifier for the CX Collection Detail Upload              | 456                            |
| external_id                        | string   | External identifier for the record                          | EXT-789                        |
| job_id                             | string   | A unique ID assigned when a batch of responses is imported  | JOB-101112                     |
| negative_ease                      | string   | Negative feedback on ease of use                            | 0,1                            |
| negative_effectiveness             | string   | Negative feedback on effectiveness                          | 0,1                            |
| negative_efficiency                | string   | Negative feedback on efficiency                             | 0,1                            |
| negative_employee                  | string   | Negative feedback on employee interaction                   | 0,1                            |
| negative_humanity                  | string   | Negative feedback on human-centered approach                | 0,1                            |
| negative_other                     | string   | Other negative feedback                                     | 0,1                            |
| negative_transparency              | string   | Negative feedback on transparency                           | 0,1                            |
| positive_ease                      | string   | Positive feedback on ease of use                            | 0,1                            |
| positive_effectiveness             | string   | Positive feedback on effectiveness                          | 0,1                            |
| positive_efficiency                | string   | Positive feedback on efficiency                             | 0,1                            |
| positive_employee                  | string   | Positive feedback on employee interaction                   | 0,1                            |
| positive_humanity                  | string   | Positive feedback on human-centered approach                | 0,1                            |
| positive_other                     | string   | Other positive feedback                                     | 0,1                            |
| positive_transparency              | string   | Positive feedback on transparency                           | 0,1                            |
| question_1                         | string   | Thumbs up/down feedback or 1-5 Likert Scale                 | 0,1 or 1,2,3,4,5               |
| question_4                         | string   | Open text feedback                                          | "This is my feedback..."       |
| updated_at                         | datetime | The timestamp when the record was last updated              | 2023-07-31 14:56:78            |