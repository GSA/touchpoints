### OMB CX Reporting Collections

An OMB CX Reporting Collection represents summary data for a single Service Channel within a CX Data Collection.
OMB collects CX Data on a quarterly basis from each of the High-impact Service Providers (HISPs).

Data is published for download at https://www.performance.gov/cx/data/.


|Field   Name | Sample Input | Format | Description|
|-- | -- | -- | --|
|id | 190 | Number | Unique   number for each set of survey responses. Each number indicates a unique   survey deployed by the HISPs. Each row corresponds to a unique survey.|
|collection_id | 57 | Number | Unique   number for a collection record. A collection record is generated for each   HISP each reporting quarter. A collection record may include multiple surveys   for the HISP service for the quarter.|
|collection_year | 2021 | Year | Year   of data collection|
|collection_quarter | 1 | Quarter | Quarter   of data collection|
|collection_name | CX   Quarterly Reporting | Text | Name   of collection; same for all HISPs|
|collection_organization_id | 2139 | Number | Unique   number for each department. A department may contain several HISPs.|
|collection_organization_name | DHS | Text | Name   of department|
|collection_organization_abbreviation | Department   of Homeland Security | Text | Abbreviation   of each department name|
|service_provider_id | 7 | Number | Unique   number for each HISP|
|service_provider_name | Customs   and Border Protection | Text | Name   of HISP|
|service_provider_organization_id | 2139 | Number | Unique   number for each department. A department may contain several HISPs.|
|service_provider_organization_name | Department   of Homeland Security | Text | Name   of department|
|service_provider_organization_abbreviation | DHS | Text | Abbreviation   of each department name|
|service_provided | Travelers   who contact the TCC about four travel programs (EVUS, ESTA, ADIS, and TTP) by   phone or email | Text | Free   text, HISP provides a description of the designated service provided at the   point of the reported survey.|
|service_id | 10 | Number | Unique   number of the designated service associated with the reported survey.|
|service_name | Contacting   the CBP contact center | Text | Name   of designated service associated with the reported survey|
|transaction_point |   | Text | Free   text, HISP provides a description of the transaction point where the reported   survey is provided to the customers.|
|channel |   | Text | Mode   by which the reported survey is deployed.|
|volume_of_customers | 0 | Number | Total   number of customers served by the HISP within the designated service for the   quarter|
|volume_of_customers_provided_survey_opportunity | 0 | Number | Total   number of customers provided with the reported customer feedback survey for   the designated service during the quarter|
|volume_of_respondents | 0 | Number | Total   number of survey responses for the quarter|
|omb_control_number | OMB   Control Number | Text | HISP   provides the OMB Control Number associated with the reported survey|
|federal_register_url | Federal   Register URL | Text | HISP   provides the Federal Register URL associated with the reported survey|
|q1_text |   | Text | Text   of the question measuring satisfaction in the reported survey|
|q1_1 | 0 | Number | Total   number of responses for 1-strongly disagree on a 1-5 bi-directional Likert Scale.|
|q1_2 | 0 | Number | Total   number of responses for 2-disagree on a 1-5 bi-directional Likert Scale.|
|q1_3 | 0 | Number | Total   number of responses for 3-neutral on a 1-5 bi-directional Likert Scale.|
|q1_4 | 0 | Number | Total   number of responses for 4-agree on a 1-5 bi-directional Likert Scale.|
|q1_5 | 0 | Number | Total   number of responses for 5-strongly agree on a 1-5 bi-directional Likert Scale.|
|q2_text |   | Text | Text   of the question measuring trust in the reported survey|
|q2_1 | 0 | Number | Total   number of responses for 1-strongly disagree on a 1-5 bi-directional Likert Scale.|
|q2_2 | 0 | Number | Total   number of responses for 2-disagree on a 1-5 bi-directional Likert Scale.|
|q2_3 | 0 | Number | Total   number of responses for 3-neutral on a 1-5 bi-directional Likert Scale.|
|q2_4 | 0 | Number | Total   number of responses for 4-agree on a 1-5 bi-directional Likert Scale.|
|q2_5 | 0 | Number | Total   number of responses for 5-strongly agree on a 1-5 bi-directional Likert Scale.|
|q3_text |   | Text | Text   of the question measuring effectiveness in the reported survey|
|q3_1 | 0 | Number | Total   number of responses for 1-strongly disagree on a 1-5 bi-directional Likert Scale.|
|q3_2 | 0 | Number | Total   number of responses for 2-disagree on a 1-5 bi-directional Likert Scale.|
|q3_3 | 0 | Number | Total   number of responses for 3-neutral on a 1-5 bi-directional Likert Scale.|
|q3_4 | 0 | Number | Total   number of responses for 4-agree on a 1-5 bi-directional Likert Scale.|
|q3_5 | 0 | Number | Total   number of responses for 5-strongly agree on a 1-5 bi-directional Likert Scale.|
|q4_text |   | Text | Text   of the question measuring ease in the reported survey|
|q4_1 | 0 | Number | Total   number of responses for 1-strongly disagree on a 1-5 bi-directional Likert Scale.|
|q4_2 | 0 | Number | Total   number of responses for 2-disagree on a 1-5 bi-directional Likert Scale.|
|q4_3 | 0 | Number | Total   number of responses for 3-neutral on a 1-5 bi-directional Likert Scale.|
|q4_4 | 0 | Number | Total   number of responses for 4-agree on a 1-5 bi-directional Likert Scale.|
|q4_5 | 0 | Number | Total   number of responses for 5-strongly agree on a 1-5 bi-directional Likert Scale.|
|q5_text |   | Text | Text   of the question measuring efficiency in the reported survey|
|q5_1 | 0 | Number | Total   number of responses for 1-strongly disagree on a 1-5 bi-directional Likert Scale.|
|q5_2 | 0 | Number | Total   number of responses for 2-disagree on a 1-5 bi-directional Likert Scale.|
|q5_3 | 0 | Number | Total   number of responses for 3-neutral on a 1-5 bi-directional Likert Scale.|
|q5_4 | 0 | Number | Total   number of responses for 4-agree on a 1-5 bi-directional Likert Scale.|
|q5_5 | 0 | Number | Total   number of responses for 5-strongly agree on a 1-5 bi-directional Likert Scale.|
|q6_text |   | Text | Text   of the question measuring transparency in the reported survey|
|q6_1 | 0 | Number | Total   number of responses for 1-strongly disagree on a 1-5 bi-directional Likert Scale.|
|q6_2 | 0 | Number | Total   number of responses for 2-disagree on a 1-5 bi-directional Likert Scale.|
|q6_3 | 0 | Number | Total   number of responses for 3-neutral on a 1-5 bi-directional Likert Scale.|
|q6_4 | 0 | Number | Total   number of responses for 4-agree on a 1-5 bi-directional Likert Scale.|
|q6_5 | 0 | Number | Total   number of responses for 5-strongly agree on a 1-5 bi-directional Likert Scale.|
|q7_text |   | Text | Text   of the question measuring employee interaction in the reported survey|
|q7_1 | 0 | Number | Total   number of responses for 1-strongly disagree on a 1-5 bi-directional Likert Scale.|
|q7_2 | 0 | Number | Total   number of responses for 2-disagree on a 1-5 bi-directional Likert Scale.|
|q7_3 | 0 | Number | Total   number of responses for 3-neutral on a 1-5 bi-directional Likert Scale.|
|q7_4 | 0 | Number | Total   number of responses for 4-agree on a 1-5 bi-directional Likert Scale.|
|q7_5 | 0 | Number | Total   number of responses for 5-strongly agree on a 1-5 bi-directional Likert Scale.|
|q8_text |   | Text | HISP   may provide text of additional question of interest.|
|q8_1 | 0 | Number | Total   number of responses for 1-strongly disagree on a 1-5 bi-directional Likert Scale.|
|q8_2 | 0 | Number | Total   number of responses for 2-disagree on a 1-5 bi-directional Likert Scale.|
|q8_3 | 0 | Number | Total   number of responses for 3-neutral on a 1-5 bi-directional Likert Scale.|
|q8_4 | 0 | Number | Total   number of responses for 4-agree on a 1-5 bi-directional Likert Scale.|
|q8_5 | 0 | Number | Total   number of responses for 5-strongly agree on a 1-5 bi-directional Likert Scale.|
|q9_text |   | Text | HISP   may provide text of additional question of interest.|
|q9_1 | 0 | Number | Total   number of responses for 1-strongly disagree on a 1-5 bi-directional Likert Scale.|
|q9_2 | 0 | Number | Total   number of responses for 2-disagree on a 1-5 bi-directional Likert Scale.|
|q9_3 | 0 | Number | Total   number of responses for 3-neutral on a 1-5 bi-directional Likert Scale.|
|q9_4 | 0 | Number | Total   number of responses for 4-agree on a 1-5 bi-directional Likert Scale.|
|q9_5 | 0 | Number | Total   number of responses for 5-strongly agree on a 1-5 bi-directional Likert Scale.|
|q10_text |   | Text | HISP   may provide text of additional question of interest.|
|q10_1 | 0 | Number | Total   number of responses for 1-strongly disagree on a 1-5 bi-directional Likert Scale.|
|q10_2 | 0 | Number | Total   number of responses for 2-disagree on a 1-5 bi-directional Likert Scale.|
|q10_3 | 0 | Number | Total   number of responses for 3-neutral on a 1-5 bi-directional Likert Scale.|
|q10_4 | 0 | Number | Total   number of responses for 4-agree on a 1-5 bi-directional Likert Scale.|
|q10_5 | 0 | Number | Total   number of responses for 5-strongly agree on a 1-5 bi-directional Likert Scale.|
|q11_text |   | Text | HISP   may provide text of additional question of interest.|
|q11_1 | 0 | Number | Total   number of responses for 1-strongly disagree on a 1-5 bi-directional Likert Scale.|
|q11_2 | 0 | Number | Total   number of responses for 2-disagree on a 1-5 bi-directional Likert Scale.|
|q11_3 | 0 | Number | Total   number of responses for 3-neutral on a 1-5 bi-directional Likert Scale.|
|q11_4 | 0 | Number | Total   number of responses for 4-agree on a 1-5 bi-directional Likert Scale.|
|q11_5 | 0 | Number | Total   number of responses for 5-strongly agree on a 1-5 bi-directional Likert Scale.|
|created_at | 2021-07-02   21:46:03 UTC | Date | Date   of survey record creation by OMB|
|updated_at | 2021-08-04   19:29:49 UTC | Date | Date   of survey record update by HISP and/or modifcation and review by OMB|
|operational_metrics |   | Text | Free   text, HISP may provide any additional text describing operational metrics   associated with designated service of the reported survey.|
