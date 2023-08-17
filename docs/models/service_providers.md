### Service Providers

A Service Providers represents a HISP (High-impact Service Provider); a federal entity, as designated by the Director of the Office of Management and Budget (OMB), that provides or funds customer-facing services, including Federal services administered at the State or local level.

OMB collects CX Data on a quarterly basis from each of the High-impact Service Providers (HISPs),
and each OMB CX Reporting Collection references a Service Provider.

Data is published for download at https://www.performance.gov/cx/data/.

|Field Name|Sample Input|Format |Description|
|:----|:----|:----|:----|
|id|36|Number|Unique number for a collection record. A collection record is generated for each HISP each reporting quarter. A record indicates whether HISP has reported survey(s) for the quarter, as well as how many surveys were reported.organization_id|2098|Number|Unique number for each department. A department may contain several HISPs.organization_abbreviation|USDA|Text|Abbreviation of each department name|
|organization_name|Department of Agriculture|Text|Name of department|
|name|Farm Service Agency|Text|Name of HISP|
|slug|usda-fsa|Text|Abbreciation of department and HISP namesdescription| |Text|Description of the HISP, services, and/or area of responsibility.notes| |Text|Field for HISP to provide additional notes.department|usda|Text|Abbreviation of department name|
|department_abbreviation|usda|Text|Abbreviation of department name|
|bureau|Farm Service Agency|Text|Name of HISP|
|url| |Text|HISP may provide a website link to their agency.|
|new|FALSE|Boolean|True or False for whether HISP is a new service provider.|
|inactive|FALSE|Boolean|True or False for whether HISP is inactive.|
