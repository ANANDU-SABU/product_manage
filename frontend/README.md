# Product Manager – Flutter Frontend

A Flutter frontend for the **Product Manager** application.

The frontend provides authentication and product management functionality and communicates with the NestJS REST API using JWT authentication.

## Tech Stack

* **Flutter**
* **Dart**
* **Provider** – State management
* **Dio** – REST API communication
* **SharedPreferences** – Local JWT token storage
* **Material 3** – UI components and theming

## Features

### Authentication

* User Sign Up
* User Sign In
* JWT authentication
* Persistent login using `SharedPreferences`
* Logout
* Form validation
* Authentication error handling

### Product Management

* View all products
* View product details
* Create products
* Update products
* Delete products
* Product ownership is enforced by the backend
* Quantity and price validation

The application supports the complete CRUD flow:

| Operation | API                        |
| --------- | -------------------------- |
| Create    | `POST /api/products`       |
| Read all  | `GET /api/products`        |
| Read one  | `GET /api/products/:id`    |
| Update    | `PATCH /api/products/:id`  |
| Delete    | `DELETE /api/products/:id` |

The PATCH endpoint is included to provide complete CRUD functionality.

## Project Structure

```text
frontend/
├── lib/
│   ├── models/
│   │   └── product.dart
│   │
│   ├── providers/
│   │   └── auth_provider.dart
│   │
│   ├── services/
│   │   └── api_service.dart
│   │
│   ├── screens/
│   │   ├── signin_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── product_list_screen.dart
│   │   ├── product_form_screen.dart
│   │   └── product_view_screen.dart
│   │
│   └── main.dart
│
├── pubspec.yaml
└── README.md
```

## Application Architecture

```text
Flutter UI
    │
    ▼
Provider
    │
    ▼
ApiService
    │
    ▼
Dio HTTP Client
    │
    ▼
NestJS REST API
    │
    ▼
Prisma ORM
    │
    ▼
SQLite Database
```

The Flutter application is responsible for the user interface, local authentication state, API communication, and displaying product data.

The backend is responsible for authentication, authorization, validation, database operations, and user-specific product ownership.

## API Configuration

The frontend communicates with the backend using:

```text
http://localhost:3000/api
```

The API base URL is configured in:

```text
lib/services/api_service.dart
```

Example:

```dart
static const String baseUrl = 'http://localhost:3000/api';
```

### Flutter Web

For Flutter Web running in Chrome, use:

```text
http://localhost:3000/api
```

Make sure the NestJS backend is running before starting the Flutter application.

## Requirements

Install the following before running the frontend:

* Flutter SDK
* Dart SDK (included with Flutter)
* Google Chrome
* VS Code or another Flutter-compatible IDE
* Running Product Manager backend

Verify Flutter installation:

```bash
flutter doctor
```

## Installation

Navigate to the frontend directory:

```bash
cd frontend
```

Install dependencies:

```bash
flutter pub get
```

## Run the Application

### Flutter Web

Run:

```bash
flutter run -d chrome
```

The application will open in Google Chrome.

### Check Available Devices

```bash
flutter devices
```

Then run the application using the selected device.

## Backend Requirement

The frontend requires the NestJS backend to be running.

From the backend directory:

```bash
cd backend
npm install
npm run start:dev
```

The backend should be available at:

```text
http://localhost:3000
```

The Flutter frontend then communicates with:

```text
http://localhost:3000/api
```

## Authentication Flow

### Sign Up

1. User enters email and password.
2. Flutter sends:

```http
POST /api/auth/signup
```

3. Backend creates the account.
4. Backend returns a JWT access token.
5. Flutter stores the token using `SharedPreferences`.
6. User is taken to the product list.

### Sign In

1. User enters email and password.
2. Flutter sends:

```http
POST /api/auth/signin
```

3. Backend validates the credentials.
4. Backend returns a JWT.
5. Flutter stores the token locally.
6. User is taken to the product list.

### Authenticated Requests

For protected product requests, the JWT is sent using:

```http
Authorization: Bearer <JWT_TOKEN>
```

## Product Flow

After authentication, the user can:

1. View the product list.
2. Add a new product.
3. Open a product to view its details.
4. Edit an existing product.
5. Delete a product.
6. Log out.

### Create Product

The product form accepts:

* Name
* Category
* Quantity
* Price

Validation ensures:

```text
Quantity >= 0
Price >= 0
```

### Update Product

The existing product information is loaded into the product form.

After editing, the frontend sends:

```http
PATCH /api/products/:id
```

The product list is refreshed after a successful update.

### Delete Product

When the user deletes a product, the frontend sends:

```http
DELETE /api/products/:id
```

The product list is then refreshed.

## Local Storage

The JWT access token is stored locally using:

```text
SharedPreferences
```

The stored token allows the application to maintain the user's login state between application launches.

On logout, the stored token is removed.

## State Management

The application uses **Provider** for authentication state.

`AuthProvider` manages:

* Loading state
* Login state
* Sign in
* Sign up
* Logout
* Token/session checking

Product API operations are handled through `ApiService`.

## HTTP Communication

The application uses **Dio** for communication with the NestJS REST API.

`ApiService` handles:

```text
Sign Up
Sign In
Get Products
Create Product
Get Product
Update Product
Delete Product
Logout / Token management
```

## Running Checks

Before submitting the project, run:

```bash
flutter analyze
```

Then build the web application:

```bash
flutter build web
```

Both commands should complete without errors.

## Recommended Verification

Verify the complete application flow:

```text
Sign Up
   ↓
Sign In
   ↓
Product List
   ↓
Create Product
   ↓
View Product
   ↓
Update Product
   ↓
Delete Product
   ↓
Logout
   ↓
Sign In Again
```

Also verify that:

* Invalid login credentials are handled correctly.
* Empty required fields are rejected.
* Quantity cannot be negative.
* Price cannot be negative.
* Protected API requests include the JWT.
* Logged-out users cannot access authenticated product operations.
* Product data is correctly displayed after create/update/delete operations.

## Troubleshooting

### Backend Connection Error

Make sure the NestJS backend is running:

```bash
cd backend
npm run start:dev
```

Then verify:

```text
http://localhost:3000
```

Also verify that the Flutter API configuration uses:

```text
http://localhost:3000/api
```

### CORS Error in Chrome

The NestJS backend should have CORS enabled:

```typescript
app.enableCors();
```

### Flutter Dependency Issues

Run:

```bash
flutter clean
flutter pub get
```

Then run:

```bash
flutter run -d chrome
```

### Analyze Errors

Run:

```bash
flutter analyze
```

Fix all reported errors before submission.

## Production Build

To create a Flutter Web production build:

```bash
flutter build web
```

The generated files are placed in:

```text
build/web/
```

## Frontend Responsibility

The Flutter frontend is responsible for:

* User interface
* Form validation
* Navigation
* Authentication state
* JWT storage
* REST API communication
* Product display
* Product creation
* Product editing
* Product deletion

The backend is responsible for:

* User authentication
* Password hashing
* JWT generation and validation
* Authorization
* Product ownership
* Database operations
* Server-side validation

## Related Project

The backend is located in:

```text
../backend
```

The complete application consists of:

```text
Product Manager
│
├── frontend
│   └── Flutter
│
└── backend
    └── NestJS + Prisma + SQLite
```

## Summary

This Flutter frontend provides the mobile/web user interface for the Product Manager application.

It implements authentication and product management through the NestJS REST API and supports the complete product CRUD workflow.
