# Permissions

Users in Touchpoints have varying levels of permissions:

1. Globally, a user is either an `Admin` or not
1. Every user belongs to an Organization, and user may be made an `Organization Manager`
1. As a User relates to a Service, a User is either a `Service Manager` or `Submission Viewer`

### Roles

Roles based on a User's `admin` flag

* `Admin` - access to all aspects of Touchpoints System

Roles based on a User's `organization_admin` flag

* `Organization Admin`

Roles based on Service Permissions

* `Service Manager` - access to all aspects of a Service, its Touchpoints, and Submissions
* `Submission Viewer` - read-only access to a Service, its Touchpoints, and Submissions

#### How do Personas map to Roles & Permissions?

* Admin has `admin` flag set
* Organization Manager, Service Manager, and Submission Viewer can login, but do not have `admin` flag set
* Service Manager can login and has `ServiceManager` role in a `UserService` record
* Submission Viewer can login and has `SubmissionViewer` role in a `UserService` record
* Public users do not login

---

For more detailed information on how each Persona can use Touchpoints, see
the [Use Cases](USE_CASES.md).
