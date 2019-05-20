# Personas

Who is Touchpoints built for?

A Persona represents a general category of user,
based on the user's behaviors and needs.
Often, Personas are "brought-to-life" via real-world examples, pictures, interviews.
Generally, Personas are a place to collect and display information related to user needs.

### List of Personas

* System Administrator - can manage all aspects of Touchpoints
* .gov Webmaster - User who manages an Organization's Touchpoints
* Organization Manager - User who manages an Organization, and its Services, Containers, and Touchpoints
* Service Manager - User who manages one or more Services, Containers, and Touchpoints
* Submission Viewer - User who `views` one or more Services, Touchpoints, Submissions
* Public users - a non logged-in public user who uses a .gov website to access and or complete a Touchpoint for a Service

#### Assumptions

* Users can only belong to 1 Organization at a time
* A User can only be added to a Service that belongs to the same Organization as the User

#### How do Personas map to Roles & [Permissions](PERMISSIONS.md)?

* Admin has `admin` flag set
* Organization Manager has `organization_manager` flag set, and permissions apply for the Organization the user belongs to
* Webmaster & Service Manager & Submission Viewer can login and do not have `admin` flag set
* Service Manager can login and has `ServiceManager` relation in a `UserService` record
* Submission Viewer can login and has `SubmissionViewer` relation in a `UserService` record
* Public users do not login

---

For more detailed information on how each Persona can use Touchpoints, see
the [Use Cases](USE_CASES.md).
