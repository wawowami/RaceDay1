# RaceDay — Event Management System

## Project Overview

RaceDay is an event management system designed for road running, walking and cycling events. The system is intended to make it easier for event organisers to manage events, participants, categories, routes and race results in one place.

Participants will be able to create an account, view available events, enter events and keep track of their results. Organisers will be able to create and manage events, manage categories and routes, and record participant results.

This repository contains the work completed for Part 1 of the project, which focuses on the system planning and database design.

## User Roles

### Organiser

An organiser will be able to:
- Create and manage events
- Manage event categories
- Manage route information
- View participant enrolments
- Capture and update participant results

### Participant

A participant will be able to:
- Create an account
- View upcoming events
- Enter an event and select a category
- View their enrolment history
- View their race results

## Project Files

The repository currently contains the following files:

- `README.md` — Project overview and documentation
- `RaceDay101.sql` — SQL Server database script
- `raceday_erd.png` — Entity Relationship Diagram
- `endpoint-plan.md` — Planned API endpoints

## Database Design

The RaceDay database contains six main tables:

- **Users** — Stores organiser and participant accounts
- **Events** — Stores information about events
- **Categories** — Stores the categories available for each event
- **Routes** — Stores route information for events
- **Enrolments** — Records participants entering event categories
- **Results** — Stores participant race results

The database uses primary keys and foreign keys to connect the tables and maintain relationships between the different parts of the system.

The ERD shows these relationships and was used as a reference when creating the SQL database.

## API Endpoint Plan

The `endpoint-plan.md` file contains the planned REST API endpoints for the RaceDay system.

The endpoints cover areas such as:

- Authentication
- Users
- Events
- Categories
- Routes
- Enrolments
- Results

The API will be developed in a later part of the project.

## SQL Database

The `RaceDay101.sql` file contains the SQL Server script used to create the RaceDay database.

The script:

- Creates the `RaceDay` database
- Creates the six database tables
- Adds primary and foreign key relationships
- Adds validation constraints
- Inserts sample data
- Includes a verification query to check the data

The script was tested using SQL Server Management Studio (SSMS).

## Testing

The database script was tested in SQL Server Management Studio to make sure that the database, tables, relationships and sample data were created correctly.

The final verification checks the number of records inserted into each table.

Expected sample data includes:

- 4 Users
- 3 Events
- 5 Categories
- 3 Routes
- 3 Enrolments
- 2 Results

## AI Tool Disclosure

AI was used to assist with the project, mainly for troubleshooting and clearing errors in the SQL script. I reviewed the suggestions, made the necessary changes, and tested the database myself in SQL Server Management Studio.

## Project Status

**Part 1 — System Planning and Database: Completed**

The next stages of the project will involve developing the REST API and MVC web application.
