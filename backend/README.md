# Product Manager – Backend

A RESTful backend API for the **Product Manager** application.

The backend is built with **NestJS and TypeScript** and provides user authentication and product management APIs. It uses **JWT authentication**, **bcrypt password hashing**, **Prisma ORM**, and **SQLite** for data storage.

---

## 1. Tech Stack

| Technology        | Purpose                     |
| ----------------- | --------------------------- |
| NestJS            | Backend framework           |
| TypeScript        | Programming language        |
| Prisma            | ORM and database access     |
| SQLite            | Database                    |
| JWT               | Authentication              |
| Passport          | JWT authentication strategy |
| bcrypt            | Password hashing            |
| class-validator   | Request validation          |
| class-transformer | Request transformation      |
| better-sqlite3    | SQLite database adapter     |
| npm               | Package management          |

---

## 2. Main Features

The backend provides:

### Authentication

* User registration
* User login
* Email uniqueness validation
* Password hashing with bcrypt
* JWT token generation
* JWT token validation
* Protected product endpoints

### Product Management

Authenticated users can:

* Create products
* View all their products
* View one product
* Update products
* Delete products

The product functionality supports the complete CRUD workflow:

```text
Create
  ↓
Read
  ↓
Update
  ↓
Delete
```

---

# 3. Project Structure

The backend follows the NestJS module-based architecture.

```text
backend/
│
├── prisma/
│   ├── migrations/
│   └── schema.prisma
│
├── src/
│   │
│   ├── auth/
│   │   ├── dto/
│   │   │   ├── signin.dto.ts
│   │   │   └── signup.dto.ts
│   │   │
│   │   ├── guards/
│   │   │   └── jwt-auth.guard.ts
│   │   │
│   │   ├── strategies/
│   │   │   └── jwt.strategy.ts
│   │   │
│   │   ├── auth.controller.ts
│   │   ├── auth.module.ts
│   │   └── auth.service.ts
│   │
│   ├── products/
│   │   ├── dto/
│   │   │   ├── create-product.dto.ts
│   │   │   └── update-product.dto.ts
│   │   │
│   │   ├── products.controller.ts
│   │   ├── products.module.ts
│   │   └── products.service.ts
│   │
│   ├── prisma/
│   │   ├── prisma.module.ts
│   │   └── prisma.service.ts
│   │
│   ├── generated/
│   │   └── ...
│   │
│   ├── app.module.ts
│   └── main.ts
│
├── .env
├── .gitignore
├── package.json
├── package-lock.json
├── prisma.config.ts
└── README.md
```

---

# 4. Architecture

The application follows this architecture:

```text
Flutter Frontend
       │
       │ HTTP / REST
       ▼
NestJS Backend
       │
       ├── Auth Module
       │      ├── Signup
       │      ├── Signin
       │      └── JWT
       │
       ├── Products Module
       │      ├── Create
       │      ├── Read
       │      ├── Update
       │      └── Delete
       │
       ▼
    Prisma ORM
       │
       ▼
   SQLite Database
```

The backend is responsible for:

* Authentication
* Authorization
* Request validation
* Password hashing
* JWT generation and validation
* Product ownership
* Database operations

The Flutter frontend is responsible for:

* User interface
* Form input
* Navigation
* Storing the JWT
* Calling the REST API
* Displaying API results

---

# 5. Database

The project uses **SQLite** as the database.

SQLite was selected because it is:

* Lightweight
* Easy to configure
* Suitable for this interview task
* Requires no separate database server
* Easy to run locally

The database is managed through Prisma.

---

# 6. Database Schema

The application contains two main models:

```text
User
Product
```

## User

The User model contains:

```text
id
email
password
createdAt
updatedAt
```

Important rules:

* `id` is a UUID.
* `email` is unique.
* Passwords are stored as bcrypt hashes.
* A user can have multiple products.

## Product

The Product model contains:

```text
id
name
category
quantity
price
userId
createdAt
updatedAt
```

Important rules:

* `id` is a UUID.
* `name` is required.
* `category` is required.
* `quantity` must be `>= 0`.
* `price` must be `>= 0`.
* Each product belongs to a user.
* Product ownership is enforced using `userId`.

Relationship:

```text
User
 │
 └─── has many ───> Products
```

---

# 7. Prisma Schema

The database relationship can be represented as:

```text
User
-------------------------
id          UUID
email       UNIQUE
password
createdAt
updatedAt
        │
        │ 1 : many
        ▼
Product
-------------------------
id
name
category
quantity
price
userId      FK → User.id
createdAt
updatedAt
```

The `userId` field ensures that products belong to the authenticated user.

---

# 8. Environment Variables

Create a `.env` file in the backend directory.

Example:

```env
DATABASE_URL="file:./dev.db"
JWT_SECRET="your-development-secret"
PORT=3000
```

### Environment variables

| Variable       | Description                    |
| -------------- | ------------------------------ |
| `DATABASE_URL` | SQLite database connection     |
| `JWT_SECRET`   | Secret used to sign JWT tokens |
| `PORT`         | Backend server port            |

### Security

Do not commit the real `.env` file or production secrets to Git.

For a shared repository, use an `.env.example` file with placeholder values:

```env
DATABASE_URL="file:./dev.db"
JWT_SECRET="change-this-secret"
PORT=3000
```

---

# 9. Installation

From the project root:

```bash
cd backend
```

Install dependencies:

```bash
npm install
```

---

# 10. Generate Prisma Client

Generate the Prisma client:

```bash
npx prisma generate
```

This generates the Prisma client used by the NestJS application.

---

# 11. Database Migration

Run the Prisma migration:

```bash
npx prisma migrate dev
```

This creates or updates the SQLite database according to the Prisma schema.

The local database will be created automatically.

---

# 12. Start the Backend

For development:

```bash
npm run start:dev
```

The server runs on:

```text
http://localhost:3000
```

The API base URL is:

```text
http://localhost:3000/api
```

---

# 13. API Overview

All API routes use the `/api` prefix.

## Authentication

```text
POST /api/auth/signup
POST /api/auth/signin
```

## Products

```text
GET    /api/products
POST   /api/products
GET    /api/products/:id
PATCH  /api/products/:id
DELETE /api/products/:id
```

Product endpoints require authentication.

---

# 14. Authentication API

## Sign Up

### Request

```http
POST /api/auth/signup
Content-Type: application/json
```

Request body:

```json
{
  "email": "user@example.com",
  "password": "123456"
}
```

### Validation

The backend validates:

* Email must be valid.
* Password must contain at least 6 characters.
* Email must be unique.

### Response

A successful signup returns a JWT access token and user information.

Example:

```json
{
  "accessToken": "JWT_TOKEN",
  "user": {
    "id": "USER_UUID",
    "email": "user@example.com"
  }
}
```

---

# 15. Sign In

### Request

```http
POST /api/auth/signin
Content-Type: application/json
```

Request body:

```json
{
  "email": "user@example.com",
  "password": "123456"
}
```

### Response

```json
{
  "accessToken": "JWT_TOKEN",
  "user": {
    "id": "USER_UUID",
    "email": "user@example.com"
  }
}
```

The Flutter application stores the returned JWT and uses it for protected requests.

---

# 16. JWT Authentication

Product endpoints are protected using JWT authentication.

The client must send:

```http
Authorization: Bearer <JWT_TOKEN>
```

Example:

```http
GET /api/products
Authorization: Bearer eyJhbGciOiJIUzI1Ni...
```

The backend:

1. Reads the JWT from the Authorization header.
2. Validates the token.
3. Extracts the authenticated user's ID.
4. Uses that user ID when accessing products.

---

# 17. Password Security

Passwords are never stored as plain text.

During signup:

```text
Plain Password
      │
      ▼
    bcrypt
      │
      ▼
Password Hash
      │
      ▼
SQLite Database
```

During signin:

```text
Entered Password
      │
      ▼
Compare with bcrypt hash
      │
      ▼
Valid / Invalid
```

This prevents the original password from being stored directly in the database.

---

# 18. Product API

## Create Product

```http
POST /api/products
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

Request:

```json
{
  "name": "Laptop",
  "category": "Electronics",
  "quantity": 5,
  "price": 75000
}
```

### Validation

```text
name       → required
category   → required
quantity   → integer >= 0
price      → number >= 0
```

Example response:

```json
{
  "id": "PRODUCT_UUID",
  "name": "Laptop",
  "category": "Electronics",
  "quantity": 5,
  "price": 75000,
  "userId": "USER_UUID",
  "createdAt": "2026-09-23T15:24:30.661Z",
  "updatedAt": "2026-09-23T15:24:30.661Z"
}
```

---

# 19. Get All Products

```http
GET /api/products
Authorization: Bearer <JWT_TOKEN>
```

Returns products belonging to the authenticated user.

Example:

```json
[
  {
    "id": "PRODUCT_UUID",
    "name": "Laptop",
    "category": "Electronics",
    "quantity": 5,
    "price": 75000
  }
]
```

Products are ordered by creation time.

---

# 20. Get One Product

```http
GET /api/products/:id
Authorization: Bearer <JWT_TOKEN>
```

Example:

```text
GET /api/products/PRODUCT_UUID
```

The backend returns the product only if it belongs to the authenticated user.

If the product does not exist or does not belong to the user:

```text
404 Not Found
```

---

# 21. Update Product

The project includes a PATCH endpoint to provide complete CRUD functionality.

```http
PATCH /api/products/:id
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

Example:

```json
{
  "name": "Gaming Laptop",
  "category": "Electronics",
  "quantity": 10,
  "price": 85000
}
```

The backend verifies that the product belongs to the authenticated user before updating it.

---

# 22. Delete Product

```http
DELETE /api/products/:id
Authorization: Bearer <JWT_TOKEN>
```

Example:

```text
DELETE /api/products/PRODUCT_UUID
```

Successful response:

```json
{
  "message": "Product deleted successfully"
}
```

The backend first checks product ownership before deleting the product.

---

# 23. User Data Isolation

Products are associated with the user who created them.

For example:

```text
User A
 ├── Product 1
 └── Product 2

User B
 ├── Product 3
 └── Product 4
```

When User A requests:

```http
GET /api/products
```

the backend returns only:

```text
Product 1
Product 2
```

User A cannot access User B's products.

The same ownership check is applied to:

* Get one product
* Update product
* Delete product

This prevents users from modifying another user's data.

---

# 24. Request Validation

The application uses NestJS `ValidationPipe` together with `class-validator`.

The global validation configuration:

```text
ValidationPipe
├── whitelist
└── transform
```

This helps ensure that incoming API data follows the expected DTO structure.

Product validation includes:

```text
Name
Category
Quantity
Price
```

For example:

```json
{
  "name": "Laptop",
  "category": "Electronics",
  "quantity": -5,
  "price": 75000
}
```

will be rejected because quantity cannot be negative.

---

# 25. NestJS Modules

The backend is divided into logical modules.

## AuthModule

Responsible for:

* Signup
* Signin
* Password hashing
* JWT generation
* JWT validation

Main files:

```text
auth.controller.ts
auth.service.ts
auth.module.ts
```

## ProductsModule

Responsible for:

* Create product
* List products
* View product
* Update product
* Delete product

Main files:

```text
products.controller.ts
products.service.ts
products.module.ts
```

## PrismaModule

Responsible for:

* Prisma client
* SQLite database connection
* Database lifecycle management

Main files:

```text
prisma.service.ts
prisma.module.ts
```

---

# 26. Request Flow

## Authentication

```text
Flutter
   │
   │ POST /auth/signup
   ▼
AuthController
   │
   ▼
AuthService
   │
   ├── Validate email
   ├── Hash password
   ├── Create user
   └── Generate JWT
   │
   ▼
Flutter receives JWT
```

## Product Request

```text
Flutter
   │
   │ Authorization: Bearer JWT
   ▼
JwtAuthGuard
   │
   ▼
JwtStrategy
   │
   ▼
ProductsController
   │
   ▼
ProductsService
   │
   ▼
Prisma
   │
   ▼
SQLite
```

---

# 27. CORS

The backend enables CORS so that the Flutter Web application running in Chrome can communicate with the API.

The application uses:

```typescript
app.enableCors();
```

This allows the frontend and backend to communicate during local development.

---

# 28. Development Commands

Install dependencies:

```bash
npm install
```

Generate Prisma client:

```bash
npx prisma generate
```

Create/update database:

```bash
npx prisma migrate dev
```

Start development server:

```bash
npm run start:dev
```

Build the backend:

```bash
npm run build
```

Run lint:

```bash
npm run lint
```

Run unit tests:

```bash
npm run test
```

Run end-to-end tests:

```bash
npm run test:e2e
```

---

# 29. Build Verification

Before submitting the project, run:

```bash
npm run build
```

The project should compile successfully without TypeScript errors.

Also run:

```bash
npm run lint
```

and:

```bash
npm run test
```

where applicable.

---

# 30. API Testing

The API can be tested using:

* Postman
* Insomnia
* Thunder Client
* curl
* The Flutter frontend

A basic testing sequence is:

```text
1. Sign Up
      ↓
2. Sign In
      ↓
3. Copy JWT
      ↓
4. Create Product
      ↓
5. Get Products
      ↓
6. Get One Product
      ↓
7. Update Product
      ↓
8. Delete Product
```

---

# 31. Example API Testing

## 1. Sign Up

```http
POST http://localhost:3000/api/auth/signup
```

```json
{
  "email": "test@example.com",
  "password": "123456"
}
```

## 2. Sign In

```http
POST http://localhost:3000/api/auth/signin
```

```json
{
  "email": "test@example.com",
  "password": "123456"
}
```

Copy the returned:

```text
accessToken
```

## 3. Create Product

```http
POST http://localhost:3000/api/products
Authorization: Bearer <TOKEN>
```

```json
{
  "name": "Laptop",
  "category": "Electronics",
  "quantity": 5,
  "price": 75000
}
```

## 4. Get Products

```http
GET http://localhost:3000/api/products
Authorization: Bearer <TOKEN>
```

## 5. Get One Product

```http
GET http://localhost:3000/api/products/<PRODUCT_ID>
Authorization: Bearer <TOKEN>
```

## 6. Update Product

```http
PATCH http://localhost:3000/api/products/<PRODUCT_ID>
Authorization: Bearer <TOKEN>
```

```json
{
  "name": "Updated Laptop",
  "category": "Electronics",
  "quantity": 10,
  "price": 80000
}
```

## 7. Delete Product

```http
DELETE http://localhost:3000/api/products/<PRODUCT_ID>
Authorization: Bearer <TOKEN>
```

---

# 32. Error Handling

The backend returns appropriate HTTP errors for invalid requests.

Common responses include:

```text
400 Bad Request
401 Unauthorized
404 Not Found
409 Conflict
```

Examples:

### Invalid credentials

```text
401 Unauthorized
```

### Duplicate email

```text
409 Conflict
```

### Missing/invalid JWT

```text
401 Unauthorized
```

### Product not found

```text
404 Not Found
```

### Invalid product data

```text
400 Bad Request
```

---

# 33. Security Considerations

The backend implements several basic security practices:

* Passwords are hashed using bcrypt.
* Passwords are not returned as API response data.
* Product routes require JWT authentication.
* JWT tokens have an expiration time.
* Product operations verify user ownership.
* Email addresses are unique.
* Request input is validated.
* Environment variables are used for secrets.
* `.env` should not be committed to Git.

For production deployment, the JWT secret should be replaced with a strong secret stored securely in the deployment environment.

---

# 34. Why SQLite?

SQLite was selected for this project because the interview task requires a relational database but does not require a separate database server.

Advantages for this project:

* Simple setup
* No database server required
* Easy local development
* Works well with Prisma
* Easy to reset during development
* Suitable for a small interview application

The application can be migrated to another relational database later if required.

---

# 35. Why Prisma?

Prisma provides:

* Type-safe database access
* Schema-based database modeling
* Database migrations
* Generated client
* Clear relationship definitions
* Easy integration with NestJS

The main database schema is defined in:

```text
prisma/schema.prisma
```

---

# 36. Why JWT?

JWT is used because the API requires authenticated product operations.

The authentication flow is:

```text
User Login
    ↓
Backend validates credentials
    ↓
Backend creates JWT
    ↓
Frontend stores JWT
    ↓
Frontend sends JWT with API requests
    ↓
Backend validates JWT
    ↓
Request allowed
```

---

# 37. Frontend Integration

The Flutter frontend communicates with this backend through the REST API.

```text
Flutter
   │
   ├── Sign Up
   ├── Sign In
   ├── Get Products
   ├── Create Product
   ├── Update Product
   ├── Get Product
   └── Delete Product
          │
          ▼
       NestJS API
```

The frontend stores the JWT locally and sends it in the Authorization header for protected endpoints.

---

# 38. Complete Application Flow

```text
                 ┌───────────────┐
                 │ Flutter Web   │
                 │   Frontend    │
                 └───────┬───────┘
                         │
                         │ REST API
                         ▼
                 ┌───────────────┐
                 │    NestJS     │
                 │    Backend    │
                 └───────┬───────┘
                         │
              ┌──────────┴──────────┐
              │                     │
              ▼                     ▼
       ┌────────────┐        ┌────────────┐
       │ Auth Module│        │  Products  │
       │            │        │   Module   │
       └────────────┘        └─────┬──────┘
                                   │
                                   ▼
                            ┌────────────┐
                            │  Prisma    │
                            │    ORM     │
                            └─────┬──────┘
                                  │
                                  ▼
                            ┌────────────┐
                            │   SQLite   │
                            └────────────┘
```

---

# 39. Recommended Verification Checklist

Before submitting the project, verify the following:

### Authentication

* [ ] User can sign up.
* [ ] Duplicate email is rejected.
* [ ] Invalid email is rejected.
* [ ] Password shorter than 6 characters is rejected.
* [ ] User can sign in.
* [ ] Invalid password is rejected.
* [ ] JWT is returned after successful authentication.
* [ ] Protected routes reject requests without JWT.

### Products

* [ ] User can create a product.
* [ ] User can view all products.
* [ ] User can view one product.
* [ ] User can update a product.
* [ ] User can delete a product.
* [ ] Negative quantity is rejected.
* [ ] Negative price is rejected.
* [ ] Product ownership is enforced.

### Security

* [ ] Passwords are hashed.
* [ ] Passwords are not returned.
* [ ] JWT is required for product endpoints.
* [ ] User A cannot access User B's products.
* [ ] `.env` is not committed.

### Build

* [ ] `npm run build` succeeds.
* [ ] `npm run lint` succeeds.
* [ ] Tests pass where configured.
* [ ] Flutter frontend can connect to the backend.

---

# 40. Submission Checklist

Before submitting the project to the company:

```text
Backend
├── NestJS application
├── TypeScript
├── Authentication
├── JWT
├── bcrypt
├── Prisma
├── SQLite
├── Product CRUD
├── Validation
├── User ownership
├── CORS
└── README

Frontend
├── Flutter
├── Sign In
├── Sign Up
├── Product List
├── Product Details
├── Create Product
├── Update Product
├── Delete Product
├── JWT storage
└── README
```

Run the final checks:

```bash
cd backend
npm install
npx prisma generate
npx prisma migrate dev
npm run build
npm run lint
npm run test
```

Then run the application:

```bash
npm run start:dev
```

The backend should be available at:

```text
http://localhost:3000
```

API base URL:

```text
http://localhost:3000/api
```

---

# 41. Summary

The Product Manager backend is a NestJS REST API that provides:

* Secure user registration and login
* JWT-based authentication
* bcrypt password hashing
* Product CRUD operations
* User-specific product ownership
* Request validation
* Prisma ORM
* SQLite database
* RESTful API endpoints
* Flutter Web integration

The backend is designed to be simple to run locally while following a clear modular NestJS architecture suitable for the Junior Full-Stack Developer interview task.
