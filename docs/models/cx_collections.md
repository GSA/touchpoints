### CX Collections

A Collection represents the 2nd version of the quarterly CX Data Collection. (Starting FY 2024)
OMB collects CX Data on a quarterly basis from each of the High-impact Service Providers (HISPs).

Data is published for download at https://www.performance.gov/cx/data/.

|Field Name | Sample Input | Format | Description |
|-- | -- | -- | -- |
| id | 59 | Number | Unique   number for a collection record. A collection record is generated for each   HISP each reporting quarter. A record indicates whether HISP has reported   survey(s) for the quarter, as well as how many surveys were reported. |
| name | CX   Quarterly Reporting | Text | Name   of collection; same for all HISPs |
| start_date | 10/1/2023 | Date | Start date of the reporting quarter |
| end_date | 12/31/2023 | Date | End date of the reporting quarter |
| service_provider_id | 36 | Number | Unique   number for each HISP |
| service_provider_name | Farm   Service Agency | Text | Name   of HISP |
| service_provider_organization_id | 2098 | Number | Unique   number for each department. A department may contain several HISPs. |
| service_provider_organization_name | Department   of Agriculture | Text | Name   of department |
| service_provider_organization_abbreviation | USDA | Text | Abbreviation   of each department name |
| organization_id | 2098 | Number | Unique   number for each department. A department may contain several HISPs. |
| organization_name | Department   of Agriculture | Text | Name   of department |
| organization_abbreviation | USDA | Text | Abbreviation   of each department name |
| user_email |   | Text | Email   of POC for each HISP |
| year | 2021 | Year | Year   of reported data |
| quarter | 1 | Quarter | Quarter   of reported data |
| reflection | This   FY21 first quarter report completes the data collection for the first annual   FPAC Producer Satisfaction Survey… | Text | Each   HISP provide a reflection text on the insights gleaned from all surveys for   the quarter. |
| created_at | 2021-07-06   20:25:51 UTC | Date | Timestamp   for creation of collection record |
| updated_at | 2021-08-04   16:29:20 UTC | Date | Timestamp   for update to the collection record. May reflection HISP POC updating records   and/or OMB reviewing data submission and approval to publish. |
| rating | PARTIAL | Text | OMB   provides a rating of the data submission after review. |
| aasm_state | draft | Text | Indicates   whether HISP records are in draft, submitted, or published. Draft is when OMB   creates the collection record. Submitted indicates that HISP has   affirmatively provided data submission. Published indicates that OMB has   reviewed and cleared data submission for publishing. OMB uses the published   tag as filter for HISPs that met the data reporting requirements. |
| integrity_hash |   | Text | This   is an auto-generated tag for unique record. |
| omb_cx_reporting_collections_count | 1 | Number | Number   of surveys submitted by the HISPs for the quarter. |