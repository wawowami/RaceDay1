# RaceDay — API Endpoint Plan (Part 1, Section B)

Roles: **None** = public, **Any** = any logged-in user, **Organiser** / **Participant** = specific role.
"(owner)" means the endpoint additionally checks that the logged-in user owns the resource
(e.g. the Organiser who created the Event, or the Participant who made the Enrolment).

## Authentication

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/auth/register | Creates a new user account as either an Organiser or a Participant. | None (public) | `{ fullName, email, password, role }` | 201 Created — user id + role. 400 Bad Request — missing/invalid fields. 409 Conflict — email already registered. |
| POST | /api/auth/login | Authenticates a user and returns a JWT access token. | None (public) | `{ email, password }` | 200 OK — `{ token, role }`. 401 Unauthorized — invalid credentials. |

## User Profile

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/users/me | Returns the profile of the currently logged-in user. | Any (logged in) | None | 200 OK — user profile. 401 Unauthorized — no/invalid token. |
| PUT | /api/users/me | Updates the logged-in user's own profile details. | Any (logged in) | `{ fullName, phoneNumber }` | 200 OK — updated profile. 400 Bad Request — invalid fields. 401 Unauthorized. |

## Events

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/events | Lists all upcoming events. Supports optional filtering (e.g. by province). | None (public) | None | 200 OK — array of events. |
| GET | /api/events/{id} | Returns full details for a single event. | None (public) | None | 200 OK — event details. 404 Not Found — event does not exist. |
| POST | /api/events | Creates a new event owned by the logged-in Organiser. | Organiser | `{ name, description, eventDate, location, province }` | 201 Created — new event. 400 Bad Request — invalid fields. 401 Unauthorized. |
| PUT | /api/events/{id} | Updates an event's details. Only the owning Organiser may edit it. | Organiser (owner) | `{ name, description, eventDate, location, province }` | 200 OK — updated event. 403 Forbidden — not the owner. 404 Not Found. |
| DELETE | /api/events/{id} | Deletes an event and its related categories/routes. | Organiser (owner) | None | 204 No Content. 403 Forbidden — not the owner. 404 Not Found. |

## Categories

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/events/{eventId}/categories | Lists all categories (distances) available for an event. | None (public) | None | 200 OK — array of categories. 404 Not Found — event does not exist. |
| POST | /api/events/{eventId}/categories | Adds a new category to an event. | Organiser (owner) | `{ name, distanceKm, maxParticipants, entryFee }` | 201 Created — new category. 400 Bad Request. 404 Not Found — event does not exist. |
| PUT | /api/categories/{id} | Updates a category's details. | Organiser (owner) | `{ name, distanceKm, maxParticipants, entryFee }` | 200 OK — updated category. 403 Forbidden. 404 Not Found. |
| DELETE | /api/categories/{id} | Removes a category from an event. | Organiser (owner) | None | 204 No Content. 403 Forbidden. 404 Not Found. |

## Routes

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/events/{eventId}/routes | Lists route/map information for an event, used for race-day prep. | None (public) | None | 200 OK — array of routes. 404 Not Found — event does not exist. |
| POST | /api/events/{eventId}/routes | Adds route details (distance, elevation, map link) to an event. | Organiser (owner) | `{ routeName, distanceKm, elevationGainM, mapUrl }` | 201 Created — new route. 400 Bad Request. 404 Not Found. |

## Event Enrolments

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/categories/{categoryId}/enrolments | Enrols the logged-in Participant into a category for an event. | Participant | None (participant taken from token) | 201 Created — enrolment record. 400 Bad Request — category full. 404 Not Found — category does not exist. 409 Conflict — already enrolled. |
| GET | /api/users/me/enrolments | Lists the logged-in Participant's own enrolment history. | Participant | None | 200 OK — array of enrolments. |
| GET | /api/categories/{categoryId}/enrolments | Lists all participants enrolled in a category, for the owning Organiser. | Organiser (owner) | None | 200 OK — array of enrolments. 403 Forbidden. 404 Not Found. |
| DELETE | /api/enrolments/{id} | Cancels an enrolment (withdraws from a category). | Participant (owner) | None | 204 No Content. 403 Forbidden. 404 Not Found. |

## Results

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/enrolments/{enrolmentId}/results | Captures a finishing result for a participant's enrolment. | Organiser (owner) | `{ finishTime, position }` | 201 Created — result record. 404 Not Found — enrolment does not exist. 409 Conflict — result already recorded. |
| PUT | /api/results/{id} | Corrects an already-captured result. | Organiser (owner) | `{ finishTime, position }` | 200 OK — updated result. 403 Forbidden. 404 Not Found. |
| GET | /api/users/me/results | Lists the logged-in Participant's personal result history. | Participant | None | 200 OK — array of results. |
| GET | /api/events/{eventId}/results | Lists all results for an event (public leaderboard). | None (public) | None | 200 OK — array of results. 404 Not Found — event does not exist. |

## API Development Status

The endpoints in this document are planned for the next stage of the RaceDay project. The current stage focusses on the database design and implementation. The REST API will be developed after the database has been completed and tested.

## Purpose

The endpoint plan provides a guide for the REST API that will be developed in the next stage of the RaceDay project. It outlines the main resources and operations that the system will need to support.
