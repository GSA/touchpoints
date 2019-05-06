# Personas

A Persona represents a general category of user,
based on the user's behaviors and needs.
Often, Personas are "brought-to-life" via real-world examples, pictures, interviews.
Generally, Personas are a place to hang information related to user needs.

* System Administrator - can manage all aspects of Touchpoints
* .gov Webmaster - User who manages an Organization's Touchpoints
* Service Manager - User who `owns` one or more Services, Containers, and Touchpoints
* Submission Viewer - User who `views` one or more Services, Touchpoints, Submissions
* Public users - a non logged-in public user who uses a .gov website to access and or complete a Touchpoint for a Service

#### How do Personas map to Roles & [Permissions](PERMISSIONS.md)?

* Admin has `admin` flag set
* Webmaster & Service Manager & Submission Viewer can login and do not have `admin` flag set
* Service Manager can login and has `ServiceManager` relation in a `UserService` record
* Submission Viewer can login and has `SubmissionViewer` relation in a `UserService` record
* Public users do not login

---

For more detailed information on how each Persona can use Touchpoints, see
the [Use Cases](USE_CASES.md).
