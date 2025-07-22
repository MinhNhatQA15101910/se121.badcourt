# BadCourt - Badminton Court Reservation System

**BadCourt** is a microservices-based application designed to simplify and digitalize the process of booking badminton courts. It supports seamless interactions for customers, court managers, and system administrators. The system allows users to browse available courts, make reservations, and process payments securely, while enabling managers to monitor bookings, view revenue reports, and manage courts efficiently.

## Key Technologies

* **.NET Core WebAPI** for backend services
* **CQRS with MediatR** for clean separation of concerns
* **FluentValidation** for request validation
* **MongoDB & PostgreSQL** for flexible data storage
* **MassTransit + RabbitMQ** for event-driven messaging
* **Stripe API** for secure online payments
* **Docker & Docker Compose** for containerized deployment
* **Flutter** for cross-platform mobile client (optional: Vue.js + NuxtJS if web client is included)
* **Ocelot** as API Gateway for routing and aggregating requests

## System Architecture

BadCourt is built with a modular microservices architecture following Domain-Driven Design (DDD). Each service handles a distinct domain such as user management, court booking, payment processing, statistics, and notifications. The services communicate asynchronously using RabbitMQ and are orchestrated through a central API Gateway.

## 🧑‍💼 Role-Based Feature Overview

### 🧍 Customer (End User)

This is the primary role for users who want to find, book, and pay for badminton court reservations.

#### Features:

* **Register & Login**
  Create an account or authenticate using secure login.

* **View Available Courts**
  Browse courts with filters by:

  * Location
  * Time slot
  * Price
  * Surface type or court type (if supported)

* **Court Details**
  View detailed information about a selected court including:

  * Available time slots
  * Court address
  * Rules or terms

* **Make Reservation**
  Choose date/time and court, and create a reservation.

* **Payment via Stripe**
  Secure online payment integration with Stripe. Supports real-time status update after transaction.

* **View Booking History**

  * Check current, past, and canceled bookings
  * View payment and court details for each booking

* **Cancel Reservation** *(If allowed by system rules)*
  Request to cancel a booking and potentially receive a refund (partial/full, depending on policy).

---

### 🏢 Manager (Court Owner or Staff)

This role manages court-related data and oversees the operational aspects of their own courts.

#### Features:

* **Court Management**

  * Add new courts (name, location, images, description, availability)
  * Update or remove existing courts
  * Set pricing and availability schedules

* **Booking Monitoring**

  * View all bookings for courts under management
  * Approve, reject, or adjust reservations (if system allows)

* **Statistics Dashboard**

  * Revenue reports by court and time period
  * Total bookings per day/week/month
  * Popular booking time slots
  * Number of unique customers
  * Export reports to CSV/Excel (if implemented)

* **Court Availability Management**

  * Open/close courts temporarily (e.g., for maintenance)
  * Block specific time slots

* **Notifications**

  * Receive notifications for new bookings or cancellations
  * Get alerts for system anomalies (e.g., payment failed, overbooking)

---

### 🛠 Admin (System Administrator)

Admins have full access across the entire platform and oversee both users and system integrity.

#### Features:

* **User & Role Management**

  * View all registered users
  * Assign or change roles (Customer, Manager, Admin)
  * Deactivate or ban users if needed

* **Court Oversight**

  * View and moderate all courts in the system
  * Remove inappropriate or inactive court listings

* **System Logs & Monitoring**

  * Track system health, failures, and service communication (via RabbitMQ logs)
  * Monitor microservices and database connectivity

* **Revenue & Usage Reports**

  * System-wide financial overview
  * Aggregated user and court statistics
  * Export platform-wide metrics

* **Audit & Security Controls**

  * View and audit actions taken by users or managers
  * Manage platform settings and security rules (e.g., cancellation policies, refund rules)

---

## 🔐 Role Access Summary Table

| Feature                             | Customer | Manager              | Admin |
| ----------------------------------- | -------- | -------------------- | ----- |
| Register / Login                    | ✅        | ✅                    | ✅     |
| Browse courts & view details        | ✅        | 🔍                   | 🔍    |
| Book courts                         | ✅        | 🔍                   | 🔍    |
| Online payment via Stripe           | ✅        | 🔍                   | 🔍    |
| View & manage own bookings          | ✅        | ✅ (for their courts) | 🔍    |
| Manage courts                       | ❌        | ✅                    | ✅     |
| View statistics                     | ❌        | ✅                    | ✅     |
| Export reports                      | ❌        | ✅                    | ✅     |
| Manage users                        | ❌        | ❌                    | ✅     |
| Assign roles                        | ❌        | ❌                    | ✅     |
| Monitor system logs                 | ❌        | ❌                    | ✅     |
| Modify global system rules/settings | ❌        | ❌                    | ✅     |

## Deployment

The system can be run locally or deployed using Docker Compose. Each service can also be started independently for development and testing. Prerequisites include .NET 7, Docker, MongoDB, PostgreSQL, and RabbitMQ.
