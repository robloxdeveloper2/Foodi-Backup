# Foodi Backend API

Flask-based backend application for the Foodi meal planning and recipe management system.

## Features

- User account creation and authentication (email/password and social login)
- JWT-based authentication
- Email verification
- Password security validation
- Social login (Google, Apple)
- Rate limiting
- Comprehensive error handling
- Database migrations
- API documentation

## Tech Stack

- **Framework**: Flask 2.3.3
- **Database**: PostgreSQL (with SQLAlchemy ORM)
- **NoSQL**: MongoDB (for flexible user preferences)
- **Authentication**: JWT tokens with Flask-JWT-Extended
- **Validation**: Pydantic
- **Email**: SMTP with HTML templates
- **Social Auth**: Google OAuth 2.0, Apple Sign In
- **Rate Limiting**: Flask-Limiter
- **Deployment**: Docker, Gunicorn

## Prerequisites

- Python 3.11+
- PostgreSQL 15+
- MongoDB 6.0+
- Redis (for rate limiting, optional)

## Setup

### 1. Clone and Navigate
```bash
cd backend
```

### 2. Create Virtual Environment
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Environment Configuration
Copy the example environment file:
```bash
cp env.example .env
```

Edit `.env` with your configuration:
```env
# Flask Configuration
SECRET_KEY=your-secret-key-here
JWT_SECRET_KEY=your-jwt-secret-key-here
FLASK_DEBUG=True

# Database Configuration
DATABASE_URL=postgresql://username:password@localhost:5432/foodi_db
MONGODB_URI=mongodb://localhost:27017/foodi_mongo

# Email Configuration (optional for development)
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
FROM_EMAIL=your-email@gmail.com

# Social Login (optional)
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
```

### 5. Database Setup
Create PostgreSQL database:
```sql
CREATE DATABASE foodi_db;
```

### 6. Run the Application
```bash
python src/main.py
```

The API will be available at `http://localhost:5000`

## API Endpoints

### Authentication

#### Register User
```http
POST /api/v1/users/register
Content-Type: application/json

{
  "username": "johndoe",
  "email": "john@example.com", 
  "password": "SecurePass123",
  "first_name": "John",
  "last_name": "Doe"
}
```

#### Login
```http
POST /api/v1/users/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "SecurePass123"
}
```

#### Social Login
```http
POST /api/v1/users/social-login
Content-Type: application/json

{
  "provider": "google",
  "access_token": "google-access-token",
  "email": "john@example.com",
  "first_name": "John",
  "last_name": "Doe"
}
```

#### Verify Email
```http
POST /api/v1/users/verify-email
Content-Type: application/json

{
  "token": "verification-token-from-email"
}
```

### User Profile

#### Get Profile
```http
GET /api/v1/users/profile
Authorization: Bearer <jwt-token>
```

#### Update Profile
```http
PUT /api/v1/users/profile
Authorization: Bearer <jwt-token>
Content-Type: application/json

{
  "first_name": "John",
  "last_name": "Smith",
  "dietary_restrictions": ["vegetarian", "gluten-free"],
  "cooking_experience_level": "intermediate",
  "nutritional_goals": {
    "calories": 2000,
    "protein": 150
  }
}
```

### Testing

#### Create Test User
```http
POST /api/v1/users/test-user
```

#### Health Check
```http
GET /api/v1/users/health
```

## Password Requirements

- Minimum 8 characters
- At least 1 uppercase letter
- At least 1 number

## Rate Limits

- Registration: 5 requests per minute
- Login: 10 requests per minute  
- Social Login: 10 requests per minute
- Profile Updates: 20 requests per hour
- Email Verification: 5 requests per minute

## Error Handling

All errors return standardized JSON responses:

```json
{
  "success": false,
  "error": {
    "code": "ValidationError",
    "message": "Validation failed",
    "error_id": "unique-error-id",
    "details": {...}
  }
}
```

Common error codes:
- `ValidationError`: Input validation failed
- `AuthenticationError`: Login failed
- `UserAlreadyExistsError`: Email/username taken
- `UserNotFoundError`: User doesn't exist
- `InvalidTokenError`: Invalid verification/JWT token
- `InternalServerError`: Unexpected server error

## Docker Deployment

### Build Image
```bash
docker build -t foodi-backend .
```

### Run Container
```bash
docker run -p 5000:5000 --env-file .env foodi-backend
```

### Docker Compose (with databases)
```yaml
version: '3.8'
services:
  backend:
    build: .
    ports:
      - "5000:5000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/foodi_db
      - MONGODB_URI=mongodb://mongo:27017/foodi_mongo
    depends_on:
      - db
      - mongo
      
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: foodi_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      
  mongo:
    image: mongo:6
    volumes:
      - mongo_data:/data/db

volumes:
  postgres_data:
  mongo_data:
```

## Development

### Code Style
- Follow PEP 8
- Use type hints
- Document functions with docstrings
- Use descriptive variable names

### Testing
```bash
# Install test dependencies
pip install pytest pytest-flask pytest-mock

# Run tests
pytest test/
```

### Database Migrations
```bash
# Initialize migrations (first time)
flask db init

# Create migration
flask db migrate -m "Description of changes"

# Apply migration
flask db upgrade
```

## Security Features

- Password hashing with bcrypt
- JWT token authentication
- Rate limiting on sensitive endpoints
- Input validation with Pydantic
- SQL injection prevention with SQLAlchemy
- XSS protection with proper serialization
- CORS configuration
- Secure headers

## Monitoring

### Logs
Application logs are structured JSON for easy parsing:
```json
{
  "timestamp": "2023-10-27T10:00:00Z",
  "level": "INFO",
  "message": "User registered successfully",
  "user_id": "uuid",
  "correlation_id": "request-id"
}
```

### Health Checks
- `/api/v1/users/health` - Service health
- Docker health check included
- Database connectivity check

## Contributing

1. Follow the coding standards outlined in `docs/operational-guidelines.md`
2. Write tests for new features
3. Update documentation
4. Ensure all tests pass
5. Follow the story-driven development process

## License

This project is part of the Foodi application suite. 