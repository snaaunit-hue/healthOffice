# Health & Environment Office - Capital Secretariat Portal

This project is a complete electronic portal system consisting of a Java Spring Boot backend and a Flutter frontend (web & mobile).

## Prerequisites
- **Java 17+**
- **Flutter 3.x**
- **Docker** (optional, recommended for database) or PostgreSQL installed locally.

## Global Quick Start
1.  **Start Database**:
    If you have Docker installed, simply run:
    ```bash
    docker-compose up -d
    ```
    This will start a PostgreSQL instance with the correct database, user, and initial seed data.

    *If not using Docker*, ensure you have a PostgreSQL database named `health_office` running on port 5432 with user `health_office` and password `health_office_password` (or update `backend/src/main/resources/application.yml`).

2.  **Start Backend**:
    Open a terminal in `backend/` and run:
    ```bash
    ./mvn spring-boot:run
    ```
    - URL: `http://localhost:8080`
    - Swagger UI: `http://localhost:8080/swagger-ui.html`
    - **Admin Login**:
      - Username: `admin`
      - Password: `password`

3.  **Start Frontend**:
    Open a new terminal in the root directory (where `pubspec.yaml` is) and run:
    ```bash
    flutter pub get
    flutter run -d chrome
    ```

## Key Features
- **Public Portal**: 
  - Dynamic content (Services, Requirements, News) fetched from backend.
  - Fully responsive design matching the specifications.
- **Facility Portal**:
  - Secure login/registration.
  - **New License Application**: Multi-step wizard (Facility Data -> Technical Supervisor -> Documents).
  - **Document Upload**: Integrated file picker system.
  - **Workflow Tracking**: Real-time status updates (Draft -> Submitted -> Review -> Inspection -> Payment -> License).
- **Admin Dashboard**:
  - Overview of key metrics (Pending Applications, Active Licenses).
  - **Application Management**: Review details, approve/reject workflow steps.
  - **Inspection Scheduling**: Manage facility visits.
- **Localization**: Native Arabic (RTL) and English support throughout the app.

## Project Structure
- `backend/`: Spring Boot API
  - `src/main/java`: Java source code (Rest Controllers, Services, Entities, Security Config).
  - `uploads/`: Directory where uploaded documents are stored.
- `lib/`: Flutter App
  - `main.dart`: Entry point.
  - `screens/`: Organized by module (Public, Auth, Portal, Admin).
  - `core/`: Shared providers (Auth, Theme, Locale), services (API), and config.
  - `widgets/`: Reusable UI components (PublicScaffold, StatusBadge, WorkflowTracker).
