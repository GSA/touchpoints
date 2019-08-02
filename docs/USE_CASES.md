# Use Cases

How [Personas](PERSONAS.md) use the system, Touchpoints.
See [Permissions](PERMISSIONS.md) for more information.

Government staff and representatives with .gov or .mil accounts
can sign up for a Touchpoints account and login. Touchpoints accounts
are not available for public Users.

### General User with Account

* A .gov or .mil staffer for an Organization existing in Touchpoints can create an Account
* User with a Touchpoints Account can login

### System Administrator

* System Administrator can manage (CRUD) Organizations
* System Administrator can manage Users
* System Administrator can manage Programs
* System Administrator can manage Services
* System Administrator can manage Touchpoints
* System Administrator can manage PRA Contacts
* System Administrator can manage Form Templates
* System Administrator can perform all the functions of a Webmaster, Service Manager, and Submission Viewer
* Webmaster can modify Triggering in Google Tag Manager

### Organization Manager `organization_manager`

* Organization Manager can manage an Organization
* Organization Manager can create a Service
* Organization Manager can add another User from the same Organization to a Service

### Webmaster `service_manager`

* Webmaster can get a .js Embed Code snippet
* Webmaster can add embed code to their website
* [outside Touchpoints] Webmaster can verify the Embed Code is working
* Webmaster to deploy website with Touchpoints embed code

### Service Manager `service_manager`

* Service Manager can edit an existing Service
* Service Manager can add another User from the same Organization as a Service Manager to a Service
* Service Manager can add another User from the same Organization as a Submission Viewer to a Service
* Service Manager can remove other Service Managers and Submissions Viewers from a Service

Within the scope a Service:

* Service Manager can create a Touchpoint
* Service Manager can edit a Touchpoint
* Service Manager can destroy a Touchpoint

* Service Manager can see a Submission
* Service Manager is notified via email when a Submission is created
* [outside Touchpoints] Service Manager to deploy Touchpoints URL via tool of choice
* Service Manager can flag a Submission

### Submission Viewer `submission_viewer`

* Submission Viewer can view list of Services they have permission to

Within the scope a Service:

* Submission Viewer receives access by being added
* Submission Viewer can view a Touchpoint and its Submissions
* Submission Viewer can see a Submission

---

## For Public Users

### Public user

A Public user does not login.

* Public User visits a public Touchpoints URL
* Public User experiences a Touchpoint delivered to a page via Google Tag Manager
  * Public User clicks a tab to see a Touchpoint
    * or Public User clicks a button to see a Touchpoint
    * or Public User *somehow triggers* an event to see a Touchpoint
* Public User creates a Submission via a Touchpoint Form
