# frozen_string_literal: true

class PraForm
  def self.part_a(form:)
    organization = form.organization

    @docx = Caracal::Document.new do |docx|
      # Define Styles
      docx.style id: 'special', size: 24 do
        name 'Special'
        bold true
      end

      docx.style do
        id   'special2'
        name 'Special2'
        size 24
        bold true
      end

      docx.style do
        id   'right-align'
        name 'right-align'
        align :right
      end

      docx.style do
        id              'indented-p' # sets the internal identifier for the style.
        name            'heading 1' # sets the friendly name of the style.
        type            'paragraph' # sets the style type. accepts `paragraph` or `character`
        # font            'Palantino' # sets the font family.
        # color           '333333'    # sets the text color. accepts hex RGB.
        # size            28          # sets the font size. units in half points.
        # bold            false       # sets the font weight.
        # italic          false       # sets the font style.
        underline       true # sets whether or not to underline the text.
        # caps            false       # sets whether or not text should be rendered in all capital letters.
        # align           :left       # sets the alignment. accepts :left, :center, :right, and :both.
        # line            360         # sets the line height. units in twips.
        # top             100         # sets the spacing above the paragraph. units in twips.
        # bottom          0           # sets the spacing below the paragraph. units in twips.
        indent_left     360         # sets the left indent. units in twips.
        indent_right    360         # sets the rights indent. units in twips.
        # indent_first    720         # sets the first line indent. units in twips.
      end

      # Layout the document

      docx.p do
        text 'Tracking and OMB Number: (XXXX) YYYY-YYYY', size: 20
        text 'Revised: 02/21/2019', align: 'right', size: 20, style: 'right-align'
        br
        text 'RIN Number: XXXX-XXXX (if applicable)', size: 20
      end
      docx.p do
      end
      docx.p do
        text 'SUPPORTING STATEMENT A'
        br
        text 'FOR PAPERWORK REDUCTION ACT SUBMISSION'
      end
      docx.p do
        text 'Clearance for Customer Experience Feedback Survey in Support of OMB Circular A-11 Section 280: Centralized Feedback Survey Administered by the General Services Administration on behalf of '
        text organization.name, underline: true, highlight_color: 'yellow'
        br
      end

      # QUESTION 1
      docx.p do
        text '1.  Explain the circumstances that make the collection of information necessary.  Identify any legal or administrative requirements that necessitate the collection.  Attach a hard copy of the appropriate section of each statute and regulation mandating or authorizing the collection of information, or you may provide a valid URL link or paste the applicable section. Specify the review type of the collection (new, revision, extension, reinstatement with change, reinstatement without change). If revised, briefly specify the changes.  If a rulemaking is involved, make note of the sections or changed sections, if applicable.'
        br
      end
      docx.p do
        style 'indented-p'
        text 'On September 11, 1993, President Clinton issued Executive Order 12862, “Setting Customer Service Standards” which clearly define his vision that the Federal agencies will put the people first. Executive Order 12862 directs Federal agencies to provide service to the public that matches or exceeds the best service available in the private sector. Section 1(b) of Executive Order 12862 requires government agencies to “survey customers to determine the kind and quality of services they want and their level of satisfaction with existing services” and Section 1(e) requires agencies “survey front-line employees on barriers to, and ideas for, matching the best in business.” '
        br
        br
        text 'On March 30, 2016, President Obama established the Core Federal Services Council, which again emphasized the need to deliver world-class customer service to the American people. The Council, composed of the major high-volume, high-impact Federal programs that provide transactional services directly to the public, were encouraged “to improve the customer experience by using public and private sector management best practices, such as conducting self-assessments and journey mapping, collecting transactional feedback data, and sharing such data with frontline and other staff.”'
        br
        br
        text 'In March 2018, the Administration of President Trump launched the President’s Management Agenda (PMA) and established new Cross-Agency Priority (CAP) Goals. Excellent service was established as a core component of the mission, service, stewardship model that frames the entire PMA, embedding a customer-focused approach in all of the PMA’s initiatives.  This model was also included in the 2018 update of the Federal Performance Framework in Circular A-11, ensuring ‘excellent service’ as a focus in future agency strategic planning efforts. The PMA included a CAP Goal on Improving Customer Experience with Federal Services, with a primary strategy to drive improvements within 25 of the nation’s highest impact programs.  This effort is supported by an interagency team and guidance in Circular A-11 requiring the collection of customer feedback data and increasing the use of industry best practices to conduct customer research.'
        br
        br
        text 'These Presidential actions and requirements establish an ongoing process of collecting customer insights and using them to improve services. This new request will enable '
        text organization.name, underline: true, highlight_color: 'yellow'
        text ' (hereafter “the Agency”) to act in accordance with OMB Circular A-11 Section 280 to ultimately transform the experience of its customers to improve both efficiency and mission delivery, and increase accountability by communicating about these efforts with the public. These collections allow for ongoing, collaborative and actionable communications between '
        text organization.name, underline: true, highlight_color: 'yellow'
        text ' and its customers and stakeholders. it will also allow feedback to contribute directly to the improvement of program management.'
        br
      end

      # QUESTION 2
      docx.p bold: true do
        text '2.  Indicate how, by whom, and for what purpose the information is to be used.  Except for a new collection, indicate the actual use the agency has made of the information received from the current collection.'
      end

      docx.p do
        text 'The General Services Administration will collect customer feedback on behalf of the Agency in line with government-wide standard CX measures outlined in OMB Circular A-11 Section 280 and enable the Agency to make improvements in service delivery based on customer insights gathered through developing an understanding of the user experience interacting with Government.'
        br
        br
        text 'For the purposes of this request, "customers" are individuals, businesses, and organizations that interact with a Federal Government agency or program, either directly or via a Federal contractor.'
        br
        br
        text '"Service delivery" or "services" refers to the multitude of diverse interactions between a customer and Federal agency such as applying for a benefit or loan, receiving a service such as healthcare or small business counseling, requesting a document such as a passport or social security card, complying with a rule or regulation such as filing taxes or declaring goods, utilizing resources such as a park or historical site, or seeking information such as public health or consumer protection notices.'
        br
        br
        text 'Surveys to be considered under this generic clearance will only include those surveys modeled on the OMB Circular A-11 CX Feedback survey to improve customer service by collecting feedback at a specific point during a customer journey. This could include upon submitting a form online on a Federal website, speaking with a call center representative, paying off a loan, or visiting a Federal service center.'
        br
        br
        text 'In an effort to develop comparable, government-wide scores that will enable cross-agency or industry benchmarking (when relevant) and a general indication of an agency’s overall customer satisfaction, OMB Circular A-11 Section 280 requires high impact services to measure their touchpoint/transactional performance in as real-time manner as possible, with respect to satisfaction and confidence/trust using the following questions, without modification. Responses will be assessed on a 5-point Likert scale (1 (strongly disagree) to 5 (strongly agree)). These questions were developed in consultation with leading organizations in customer experience both in the private sector and industry groups that study the most critical drivers of customer experience.'
        br
      end
      docx.ul do
        li '5 point Likert scale: I am satisfied with the service I received from [Program/Service name].'
        li '5 point Likert scale: This interaction increased my confidence in [Program/Service name]. OR I trust [Agency/Program/Service name] to fulfill our country’s commitment to [relevant population].'
        li 'Free response: Any additional feedback on your scores above?'
        li '5 point Likert scale: My need was addressed OR My issue was resolved. OR I found what I was looking for.'
        li '5 point Likert scale: It was easy to complete what I needed to do.'
        li '5 point Likert scale: It took a reasonable amount of time to do what I needed to do.'
        li '5 point Likert scale: I was treated fairly.'
        li '5 point Likert scale: Employees I interacted with were helpful.'
        li 'Free response: Any additional feedback for [Program/Service name]?'
      end
      docx.p
      docx.p do
        text 'The surveys shall include no more than 15 questions in total. The Agency, in consultation with the General Services Administration, may add a few additional questions to those listed above to clarify type of service received, inquiry type, service center location, or other program-specific questions that can help program managers to filter and make use of the feedback data. These customizations will be outlined in Supporting Statement B for each agency’s survey.'
        text 'As part of the Customer Experience CAP goal’s strategy to increase transparency to drive accountability, the feedback data collected through the A-11 Standard Feedback survey is meant to be shared with the public. This collection is part of the government-wide effort to embed standardized customer metrics within high-impact programs to create government-wide performance dashboards. Data collected from the questions listed above will be submitted by the General Services Administration to OMB on a recurring basis on behalf of the Agency for the updating of customer experience dashboards on performance.gov. This dashboard will also include the total volume of customers that passed through the transaction point at which the survey was offered, the number of customers the survey was presented to, the number of responses, and the mode of presentation and response (online survey, in-person, post-call touchtone, mobile, email). This will help to qualify the data’s representation by showing both the response rate and total number of actual responses. The current template used by OMB to collect this data is included in this package.'
        br
      end
      docx.p do
        text 'Describe whether, and to what extent, the collection of information involves the use of automated, electronic, mechanical, or other technological collection techniques or forms of information technology, e.g. permitting electronic submission of responses, and the basis for the decision of adopting this means of collection.  Also describe any consideration given to using technology to reduce burden.'
        br
        br
        text 'The General Services Administration has developed and administers software that agencies can use at no cost to collect basic customer feedback in line with government-wide Customer Experience measures.'
        br
      end
      docx.p do
        text '4.  Describe efforts to identify duplication.  Show specifically why any similar information already available cannot be used or modified for use for the purposes described in Item 2 above.'
        br
        br
        text 'The purpose of this collection is to streamline, standardize, and centralize customer feedback collections government-wide to be as simple for the public as possible to complete and in line with leading CX feedback collection practices. It will also enable agencies and programs to quickly spin-up feedback surveys without having to procure survey tools until appropriate for a more robust voice of the customer program. Working with the General Services Administration to administer this collection will also require agencies to have deliberate conversations about how they are instrumenting individual interactions and asking only questions that can provide actionable feedback for improving service delivery.'
        br
      end
      docx.p do
        text '5.  If the collection of information impacts small businesses or other small entities, describe any methods used to minimize burden. A small entity may be (1) a small business which is deemed to be one that is independently owned and operated and that is not dominant in its field of operation; (2) a small organization that is any not-for-profit enterprise that is independently owned and operated and is not dominant in its field; or (3) a small government jurisdiction, which is a government of a city, county, town, township, school district, or special district with a population of less than 50,000.'
        br
        br
        text 'The information collected in these surveys will represent the minimum burden necessary to evaluate customer experience with the Agency’s programs and processes. The Agency will minimize the burden on respondents by sampling as appropriate, asking for readily available information, and using short, easy-to-complete information collection instruments.'
        br
      end

      docx.p do
        text '6.  Describe the consequences to Federal program or policy activities if the collection is not conducted or is conducted less frequently, as well as any technical or legal obstacles to reducing burden.'
        br
        br
        text 'Without regular mechanisms for collecting and generating customer insights, the Agency is not able to provide the public with the highest level of service.  These activities will be coordinated to ensure that individual respondents will not be asked to respond to more than one survey instrument per transaction.'
        br
        br
        text '7. Explain any special circumstances that would cause an information collection to be conducted in a manner:'
        br
      end
      docx.ul do
        li 'requiring respondents to report information to the agency more often than quarterly;'
        li 'requiring respondents to prepare a written response to a collection of information in fewer than 30 days after receipt of it;'
        li 'requiring respondents to submit more than an original and two copies of any document;'
        li 'requiring respondents to retain records, other than health, medical, government contract, grant-in-aid, or tax records for more than three years;'
        li 'in connection with a statistical survey, that is not designed to produce valid and reliable results than can be generalized to the universe of study;'
        li 'requiring the use of a statistical data classification that has not been reviewed and approved by OMB;'
        li 'that includes a pledge of confidentiality that is not supported by authority established in statute or regulation, that is not supported by disclosure and data security policies that are consistent with the pledge, or that unnecessarily impedes sharing of data with other agencies for compatible confidential use; or'
        li 'requiring respondents to submit proprietary trade secrets, or other confidential information unless the agency can demonstrate that it has instituted procedures to protect the information’s confidentiality to the extent permitted by law.'
      end
      docx.p
      docx.p do
        text 'These surveys will be consistent with all the guidelines in 5 CFR 1320.5, especially those provisions in subsection (g) which require that a statistical survey be designed to produce results that can be generalized to the universe of study.  There are no special circumstances that would cause this information collection to be conducted in an unusual or intrusive manner.  All participation will be voluntary.  Should the Agency need to deviate from the requirements outlined in 5 CFR 1320, individual justification will be provided to OMB on a case-by-case basis.'
        br
        br
        text '8. As applicable, state that the Department has published the 60 and 30 Federal Register notices as required by 5 CFR 1320.8(d), soliciting comments on the information collection prior to submission to OMB.  Summarize public comments received in response to that notice and describe actions taken by the agency in response to these comments.  Specifically address comments received on cost and hour burden.'
        br
        br
        text 'Describe efforts to consult with persons outside the agency to obtain their views on the availability of data, frequency of collection, the clarity of instruction and record keeping, disclosure, or reporting format (if any), and on the data elements to be recorded, disclosed, or reported.'
        br
        br
        text 'Consultation with representatives of those from whom information is to be obtained or those who must compile records should occur at least once every 3 years – even if the collection of information activity is the same as in prior periods.  There may be circumstances that may preclude consultation in a specific situation.  These circumstances should be explained.'
        br
        br
        text 'The 60-day public comment notice was published in the Federal Register May 27, 2016, page 33667.  One comment was received, see attached document for response.'
        br
        br
        text 'This is the request for the 30-day federal register notice soliciting public comment on the information collections prior to submission to OMB.'
        br
        br
        text '9. Explain any decision to provide any payment or gift to respondents, other than remuneration of contractors or grantees with meaningful justification.'
        br
        br
        text 'The standard will be no payment or gift to respondents for participation.  If any payments are proposed the Agency will submit specific justification for each proposed use as part of the completed package submitted to OMB.'
        br
        br
        text '10. Describe any assurance of confidentiality provided to respondents and the basis for the assurance in statute, regulation, or agency policy. If personally identifiable information (PII) is being collected, a Privacy Act statement should be included on the instrument. Please provide a citation for the Systems of Record Notice and the date a Privacy Impact Assessment was completed as indicated on the IC Data Form. A confidentiality statement with a legal citation that authorizes the pledge of confidentiality should be provided. If the collection is subject to the Privacy Act, the Privacy Act statement is deemed sufficient with respect to confidentiality. If there is no expectation of confidentiality, simply state that the Department makes no pledge about the confidentially of the data.'
        br
        br
        text 'Activity and survey instructions will provide all necessary assurances of confidentiality to the respondents.  Although there is no requirement for such an assurance in statute, the quality of this type of information requires respondent candor and anonymity.'
        br
        br
        text '11. Provide additional justification for any questions of a sensitive nature, such as sexual behavior and attitudes, religious beliefs, and other matters that are commonly considered private.  The justification should include the reasons why the agency considers the questions necessary, the specific uses to be made of the information, the explanation to be given to persons from whom the information is requested, and any steps to be taken to obtain their consent.'
        br
        br
        text 'No questions will be asked that are of a personal or sensitive nature.'
        br
        br
        text '12. Provide estimates of the hour burden of the collection of information.  The statement should:'
      end
      docx.ul do
        li 'Indicate the number of respondents by affected public type (federal government, individuals or households, private sector – businesses or other for-profit, private sector – not-for-profit institutions, farms, state, local or tribal governments), frequency of response, annual hour burden, and an explanation of how the burden was estimated, including identification of burden type: recordkeeping, reporting or third party disclosure.  All narrative should be included in item 12. Unless directed to do so, agencies should not conduct special surveys to obtain information on which to base hour burden estimates.  Consultation with a sample (fewer than 10) of potential respondents is desirable.  If the hour burden on respondents is expected to vary widely because of differences in activity, size, or complexity, show the range of estimated hour burden, and explain the reasons for the variance.  Generally, estimates should not include burden hours for customary and usual business practices.'
        li 'If this request for approval covers more than one form, provide separate hour burden estimates for each form and aggregate the hour burdens in the ROCIS IC Burden Analysis Table.  (The table should at minimum include Respondent types, IC activity, Respondent and Responses, Hours/Response, and Total Hours)'
        li 'Provide estimates of annualized cost to respondents of the hour burdens for collections of information, identifying and using appropriate wage rate categories.  The cost of contracting out or paying outside parties for information collection activities should not be included here.  Instead, this cost should be included in Item 14.'
      end
      docx.p
      docx.p do
        text 'A variety of instruments and platforms will be used to collect information from respondents.  The annual burden hours requested (300,000) are based on the number of collections we expect to conduct over the requested period for this clearance.'
        br
        br
        text '[Insert Burden Calculation Table - overestimate to provide flexibility]'
        br
        br
        text 'Industry best practice is to present every customer the opportunity to provide feedback at each instrumented touchpoint/transaction in a customer journey (ex. After submitting an application, completing a call at a call center, or visiting an in-person service center). The Agency will specify the total possible number of respondents based on estimated annual volume, but this information collection sets a ceiling estimate of 300,000 annually.'
        br
        br
        text 'The Agency will keep track of the above activities in order to accurately update burden calculations year to year.'
        br
        br
        text '13.  Provide an estimate of the total annual cost burden to respondents or record keepers resulting from the collection of information.  (Do not include the cost of any hour burden shown in Items 12 and 14.)'
        br
      end
      docx.ul do
        li 'The cost estimate should be split into two components: (a) a total capital and start-up cost component (annualized over its expected useful life); and (b) a total operation and maintenance and purchase of services component.  The estimates should take into account costs associated with generating, maintaining, and disclosing or providing the information.  Include descriptions of methods used to estimate major cost factors including system and technology acquisition, expected useful life of capital equipment, the discount rate(s), and the time period over which costs will be incurred.  Capital and start-up costs include, among other items, preparations for collecting information such as purchasing computers and software; monitoring, sampling, drilling and testing equipment; and acquiring and maintaining record storage facilities.'
        li 'If cost estimates are expected to vary widely, agencies should present ranges of cost burdens and explain the reasons for the variance.  The cost of contracting out information collection services should be a part of this cost burden estimate.  In developing cost burden estimates, agencies may consult with a sample of respondents (fewer than 10), utilize the 60-day pre-OMB submission public comment process and use existing economic or regulatory impact analysis associated with the rulemaking containing the information collection, as appropriate.'
        li 'Generally, estimates should not include purchases of equipment or services, or portions thereof, made: (1) prior to October 1, 1995, (2) to achieve regulatory compliance with requirements not associated with the information collection, (3) for reasons other than to provide information or keep records for the government or (4) as part of customary and usual business or private practices. Also, these estimates should not include the hourly costs (i.e., the monetization of the hours) captured above in Item 12'
      end
      docx.p do
        text 'No costs for respondents are anticipated.'
        br
        br
        text '14. Provide estimates of annualized cost to the Federal government.  Also, provide a description of the method used to estimate cost, which should include quantification of hours, operational expenses (such as equipment, overhead, printing, and support staff), and any other expense that would not have been incurred without this collection of information.  Agencies also may aggregate cost estimates from Items 12, 13, and 14 in a single table.'
        text 'Agency Cost: The Agency will leverage the GSA shared survey solution available to agencies at no cost. The General Services Administration represents an annual fixed cost as part of an appropriated budget to operate government-wide feedback analytics.'
        br
        br
        text '15. Explain the reasons for any program changes or adjustments. Generally, adjustments in burden result from re-estimating burden and/or from economic phenomenon outside of an agency’s control (e.g., correcting a burden estimate or an organic increase in the size of the reporting universe). Program changes result from a deliberate action that materially changes a collection of information and generally are result of new statute or an agency action (e.g., changing a form, revising regulations, redefining the respondent universe, etc.). Burden changes should be disaggregated by type of change (i.e., adjustment, program change due to new statute, and/or program change due to agency discretion), type of collection (new, revision, extension, reinstatement with change, reinstatement without change) and include totals for changes in burden hours, responses and costs (if applicable).'
        br
        br
        text 'N/A'
        br
      end
      docx.p do
        text '16. For collections of information whose results will be published, outline plans for tabulation and publication.  Address any complex analytical techniques that will be used.  Provide the time schedule for the entire project, including beginning and ending dates of the collection of information, completion of report, publication dates, and other actions.'
        br
        br
        text 'Customer feedback data is meant to complement and help to contextualize performance and evaluation data as part of a three-pronged approach to understanding Federal program implementation and opportunities for improvement (Performance, Evaluation, and “Feedback” data).'
        br
        br
        text 'Touchpoint surveys are to be implemented at transaction points along the customer journey interacting with Federal services, and data from the A-11 Standard CX Feedback survey will be submitted to OMB regularly for review and publication in a summary dashboard on performance.gov.'
        br
        br
        text 'This data will include:'
      end
      docx.ul do
        li 'Specific transaction point at which the survey was administered'
        li 'Total volume of customers that interacted at this transaction point during the given quarter'
        li 'Total volume of customers that were presented the survey'
        li 'Total number of customers who completed the survey'
        li 'Mode(s) of collection (ex. online, over mobile, over the phone, paper form)'
        li 'Specific survey instrument that shows the Agency’s wording of standard A-11 CX Feedback survey'
        li 'Distribution of the responses across the 5 point Likert scale for each of the standard questions'
      end
      docx.p
      docx.p do
        text 'The purpose of collecting volume and response numbers is to share customer feedback measures in context of the response rate and total volume of responses to qualify interpretation of the CX feedback data.'
      end
      docx.p do
        text '17. If seeking approval to not display the expiration date for OMB approval of the information collection, explain the reasons that display would be inappropriate.'
        br
        br
        text 'The General Services Administration will include the OMB Control Number and collection expiration date on start page of each survey.'
      end
      docx.p do
        text '18. Explain each exception to the certification statement identified in the Certification of Paperwork Reduction Act.'
        br
        br
        text 'The Agency is not requesting an exception to the certification statement identified in Item 20, “Certification for Paperwork Reduction Act Submissions, “ of OMB Form 83-I.'
      end

      # docx.table touchpoints.collect { |tp| [tp.id, tp.name] }, border_size: 4 do
      #   cell_style rows[0], background: 'cccccc', bold: true
      # end
    end

    @docx
  end
end
