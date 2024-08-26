### CX Collections

A Collection represents the 2nd version of the quarterly CX Data Collection. (Starting FY 2024)
OMB collects CX Data on a quarterly basis from each of the High-impact Service Providers (HISPs).

Data is published for download at https://www.performance.gov/cx/data/.

| Field Name                               | Format   | Description                                                                 | Sample Input                          |
|------------------------------------------|----------|-----------------------------------------------------------------------------|---------------------------------------|
| aasm_state                               | string   | The state of the record                                                     | published                             |
| created_at                               | datetime | The timestamp when the record was created                                   | 2024-03-26T20:46:03.778Z              |
| fiscal_year                              | string   | The fiscal year of the report                                               | 2024                                  |
| id                                       | integer  | Unique record id                                                            | 123                                   |
| integrity_hash                           | string   | A hash value for data integrity                                             | asf908asdf90-8sd90asd8fasddsadsf8     |
| name                                     | string   | Name of the report                                                          | CX Quarterly Reporting                |
| organization_id                          | integer  | Identifier for the organization                                             | 2098                                  |
++| organization_name (Service provider    | integer  | Organization Name                                                           | General Services Administration       |
| quarter                                  | string   | The quarter of the fiscal year                                              | 2                                     |
| rating                                   | string   | The rating for the service                                                  | true,false,partial                    |
++| service_name                           | string   | Name for the service                                                        | USA.gov                               |
| service_provider_id                      | integer  | Unique ID for the Service Provider                                          | 36                                    |
++| service_provider_name                  | integer  | Name of the Federal Agency Service Provider                                 | Public Experience Portfolio           |
| submitted_at                             | datetime | The timestamp when the report was submitted                                 | 2024-06-12T15:38:13.751Z              |
| updated_at                               | datetime | The timestamp when the record was last updated                              | 2024-06-12T15:38:25.098Z              |
| user_id                                  | integer  | Unique ID for the user                                                      | 2086                                  |


++|cx_collection_details_count            | integer  | Identifier for the user                                                      | 3                                  |
