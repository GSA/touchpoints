### Services

A Service represents a service provided by a federal government agency.

OMB collects CX Data on a quarterly basis from each of the High-impact Service Providers (HISPs),
and each OMB CX Reporting Collection references a Services.

Data is published for download at https://www.performance.gov/cx/data/.

|Field Name|Sample Input|Format |Description|
|:----|:----|:----|:----|
|id|2|Number|Unique identifier for a Service.|
|name|Receiving outpatient services|Text|Name of designated service of the HISP|
|description|VHA sends email surveys to everyone who receives outpatient services. |Text|HISP provides a description of the designated service.|
|organization_id|2129|Number|Unique number for each department. A department may contain several HISPs|
|organization_abbreviation|VA|Text|Abbreviation of each department name|
|organization_name|Department of Veterans Affairs|Text|Name of department|
|service_provider_id|21|Number|Unique number for each HISP|
|service_provider_name|Veterans Health Administration|Text|Name of HISP|
|service_provider_slug|va-vha|Text|Abbreviation of department and HISP names|
|contact_center|FALSE|Boolean|True or False for whether the service involves a contact center and/or an interaction with a contact center|
|kind|[]|Text|Identifies the category of service: compliance, administrative, benefits, recreation, informational, data and research, and regulatory|
|transactional|FALSE|Boolean|True or False for whether the service is transactional|
|notes| |Text|Field for HISP to provide additional notes|
|hisp|FALSE|Boolean|True or False for identifying the agency as a HISP|
|department|va|Text|Abbreviation of department name|
|bureau|Veterans Health Administration|Text|Name of HISP|
|service_slug|va-vha|Text|Abbreviation of department and HISP names|
|url| |Text|HISP may provide a website link to their service|
|homepage_url| |Text|HISP may provide a website link to their service|
|channels|[]|Text|HISP select channel(s) where their service is delivered|
|tags|[]|Text|HISP may add tags as needed. No strict guidance on tag type|
|available_in_person|FALSE|Boolean|True or False for whether service is available in person|
|available_digitally|FALSE|Boolean|True or False for whether service is available digitally|
|available_via_phone|FALSE|Boolean|True or False for whether service is available through telephone. |
