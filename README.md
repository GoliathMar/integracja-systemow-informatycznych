# Information Systems Integration

An academic project presenting the design assumptions for a distributed system that supports end-to-end medical service workflows: appointment booking, payment handling, notifications, and medical history management.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Core Features](#core-features)
3. [User Roles and Permissions](#user-roles-and-permissions)
4. [System Architecture](#system-architecture)
5. [External Integrations](#external-integrations)
6. [Inter-Service Communication](#inter-service-communication)
7. [BPMN Business Processes](#bpmn-business-processes)
8. [System Requirements](#system-requirements)
9. [Proposed AWS Infrastructure](#proposed-aws-infrastructure)
10. [Repository Structure](#repository-structure)

## Project Overview

The goal of this project is to design and implement a distributed information system for comprehensive handling and registration of medical services (for example, specialist doctor appointments).

The system is intended to provide:
- digitalization of the appointment booking process,
- automation of financial settlements,
- improved communication between medical facilities and patients.

## Core Features

- Patient appointment registration (searching for available slots, selecting a specialist, and reserving a time window).
- Appointment calendar management (defining availability, blocking slots, and canceling appointments).
- Online payment support (payment gateway integration and transaction status confirmation).
- Appointment notifications (confirmations, reminders, and status change messages via email/calendar).
- Visit history management (consultation archive, recommendations, invoices/receipts).

## User Roles and Permissions

### Patient
- Search for available terms and specialists.
- Book, pay for, and cancel their own appointments.
- Access treatment history and documents.

### Doctor
- Manage their own schedule and availability.
- View planned appointments by day/week.
- Add medical notes and recommendations.

### Administrator
- Manage user accounts and roles.
- Configure services, price lists, and integration parameters.
- Access operational logs and financial reports.

## System Architecture

The system is based on a microservices architecture.

Architectural assumptions:
- independent service scaling and deployment,
- fault isolation between components,
- synchronous communication (REST API) for operations requiring immediate response,
- asynchronous communication (RabbitMQ) for background processes and domain events.

## External Integrations

- PayU: payment processing for appointments, transaction creation, and webhook handling for status updates.
- Gmail API / Google Calendar API: automatic email delivery and synchronization of appointment events.

## Inter-Service Communication

### REST API and OpenAPI
- Each microservice exposes a stateless REST API.
- API contracts are described in OpenAPI 3.0.

### Data Validation
- API input payloads are validated using JSON Schema.
- Invalid requests are rejected with HTTP 400 Bad Request.

### RabbitMQ
- The broker handles asynchronous communication and domain events.
- Event routing and message durability mechanisms are applied.

Example events:
- appointment.created
- appointment.canceled
- payment.success
- payment.failed

## BPMN Business Processes

The repository contains BPMN models in the BPMN directory.

### Main Diagrams

| BPMN File | Process Scope |
| --- | --- |
| BPMN/ClerkRegistrationAdmin.bpmn | Creating a registration clerk account by an administrator |
| BPMN/DoctorRegistrationClerk.bpmn | Doctor registration by a clerk |
| BPMN/FacilityRegistrationAdmin.bpmn | Facility registration by an administrator |
| BPMN/PatientPortal.bpmn | Patient portal scenarios and interaction with the payment system |
| BPMN/PatientRegistartion(1).bpmn | Patient registration (model variant) |
| BPMN/PatientRegistration.bpmn | Patient registration |
| BPMN/VisitCancelationClerk.bpmn | Appointment cancellation by a clerk |
| BPMN/VisitCancelationDoctor.bpmn | Appointment cancellation involving doctor and PayU |
| BPMN/VisitCancelationPatient.bpmn | Appointment cancellation by a patient |
| BPMN/VisitFinishingDoctor.bpmn | Appointment finalization by a doctor |
| BPMN/VisitRegistrationClerk.bpmn | Appointment registration by a clerk |
| BPMN/VisitRegistrationPatient.bpmn | Appointment registration by a patient |

### Integration Participants Visible in the Models

- Medical system
- Payment system / PayU
- Business actors: patient, doctor, clerk, administrator

### Orchestration Process (Example)

Reference model for payment and reservation finalization:
1. The orchestrator initiates payment (PayU).
2. After payment confirmation, the appointment status is updated.
3. Once the status is updated, notifications and calendar synchronization are triggered.
4. If an error occurs, compensating actions are executed (for example, a refund).

## System Requirements

### Functional Requirements (Summary)
- Account registration, login, and session management.
- Searching for doctors and available terms.
- Appointment booking, slot blocking, and payment time-limit handling.
- PayU integration and webhook handling.
- Email confirmations and reminders, plus Google Calendar synchronization.
- Appointment cancellation and refund handling.
- Doctor availability management and visit history access.
- Administration of dictionaries, price lists, accounts, and roles.
- Audit trail for appointment and payment status changes.

### Non-Functional Requirements (Summary)
- Performance SLA targets for API read and write operations.
- Support for at least 100 concurrent users.
- Payment webhook processing within 60 seconds.
- Message durability and idempotency for critical operations.
- GDPR compliance plus encryption in transit and at rest.
- Authentication, authorization, and complete audit logging for critical operations.
- Database backup at least once daily with a minimum 30-day retention period.
- Monitoring stack: centralized logs, metrics, and alerting.

## Proposed AWS Infrastructure

- Amazon EC2 / ECS: running microservices (student variant: EC2 + Docker Compose).
- Amazon RDS (PostgreSQL): relational data layer.
- Amazon S3: static frontend hosting and potential attachment storage.
- Application Load Balancer (ALB): inbound HTTP/HTTPS traffic distribution.

## Repository Structure

```text
.
|-- README.md
|-- LICENSE
|-- BPMN/
|   |-- ClerkRegistrationAdmin.bpmn
|   |-- DoctorRegistrationClerk.bpmn
|   |-- FacilityRegistrationAdmin.bpmn
|   |-- PatientPortal.bpmn
|   |-- PatientRegistartion(1).bpmn
|   |-- PatientRegistration.bpmn
|   |-- VisitCancelationClerk.bpmn
|   |-- VisitCancelationDoctor.bpmn
|   |-- VisitCancelationPatient.bpmn
|   |-- VisitFinishingDoctor.bpmn
|   |-- VisitRegistrationClerk.bpmn
|   |-- VisitRegistrationPatient.bpmn
|   `-- templates/
```

## Authors

- Marcin Goliasz
- Andrzej Manderla
- Mateusz Gawlowski
- Wojciech Tobolski
