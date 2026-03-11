# AI Career Guidance System

An AI-powered career guidance web application built for **Mount Kigali University (MKU)** that helps students choose suitable career paths based on their interests, academic performance, and skills.

## Overview

The AI Career Guidance System is a smart digital tool designed to provide personalized career recommendations that guide students toward professions where they are most likely to succeed. It is integrated into MKU's career guidance and student support centers.

### Key Features

- **AI-Powered Career Assessment** — Multi-dimensional questionnaire covering interests, skills, personality traits, and academic strengths
- **Personalized Recommendations** — Match scores with detailed career information including education paths, salary ranges, and job outlook
- **Career Exploration** — Browse 8 career categories with detailed career profiles
- **Assessment History** — Track and review past assessments and how career interests evolve
- **Admin Dashboard** — Monitor students, assessments, recommendations, and contact messages
- **Responsive Modern UI** — Clean, professional interface that works on desktop and mobile

### Users

| Role | Description | Credentials |
|------|-------------|-------------|
| **Student** | Register and log in to take assessments and view career recommendations | Self-registration |
| **Admin** | Manage students, view analytics, and review contact messages | Username: `admin` / Password: `admin` |

## Tech Stack

- **Backend**: Python 3.10+, Flask 3.x
- **Database**: MySQL
- **Authentication**: Flask-Login + Flask-Bcrypt
- **Frontend**: Jinja2 Templates, Vanilla CSS, Vanilla JS
- **Icons**: Font Awesome 6

## Project Structure

```
ai-career/
├── app/
│   ├── __init__.py              # Flask app factory
│   ├── models.py                # User model and database helpers
│   ├── routes/
│   │   ├── main.py              # Home, About, Contact pages
│   │   ├── auth.py              # Login, Register, Logout
│   │   ├── admin.py             # Admin dashboard and management
│   │   └── career.py            # Assessment, Results, Explore, History
│   ├── templates/
│   │   ├── base.html            # Base layout template
│   │   ├── home.html            # Landing page
│   │   ├── about.html           # About Us page
│   │   ├── contact.html         # Contact form page
│   │   ├── login.html           # Login page
│   │   ├── register.html        # Registration page
│   │   ├── admin/               # Admin templates
│   │   │   ├── dashboard.html
│   │   │   ├── users.html
│   │   │   ├── user_detail.html
│   │   │   └── messages.html
│   │   └── career/              # Career guidance templates
│   │       ├── dashboard.html
│   │       ├── assessment.html
│   │       ├── results.html
│   │       ├── history.html
│   │       └── explore.html
│   └── static/
│       ├── css/style.css        # All styles
│       └── js/main.js           # Client-side interactivity
├── .cursor/rules/               # Cursor IDE rules
├── config.py                    # App configuration
├── database.sql                 # MySQL schema and seed data
├── run.py                       # Application entry point
├── requirements.txt             # Python dependencies
└── README.md
```

## Setup & Installation

### Prerequisites

- Python 3.10 or higher
- MySQL Server 5.7+ or 8.x
- pip (Python package manager)

### 1. Clone the Repository

```bash
cd C:\Users\karim\Documents\PROJECTS\ai-career
```

### 2. Create a Virtual Environment

```bash
python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # macOS/Linux
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Set Up the Database

Open MySQL and run the SQL file:

```bash
mysql -u root -p < database.sql
```

Or open `database.sql` in MySQL Workbench and execute it. This will:
- Create the `ai_career_guidance` database
- Create all required tables
- Seed career categories, careers, assessment questions, and options
- Create the admin account (username: `admin`, password: `admin`)

### 5. Configure Database Connection

Edit `config.py` if your MySQL credentials differ from the defaults:

```python
MYSQL_HOST = "localhost"
MYSQL_USER = "root"
MYSQL_PASSWORD = ""          # Set your MySQL password
MYSQL_DB = "ai_career_guidance"
```

### 6. Run the Application

```bash
python run.py
```

The application will be available at: **http://localhost:5000**

## Usage

### For Students

1. **Register** — Create an account on the registration page
2. **Login** — Sign in with your credentials
3. **Take Assessment** — Answer 15 career-related questions
4. **View Results** — See your top career matches with scores and details
5. **Explore Careers** — Browse all career categories and paths
6. **Review History** — Track your past assessments over time

### For Admins

1. **Login** — Sign in with `admin` / `admin`
2. **Dashboard** — View system statistics (users, assessments, messages)
3. **Manage Students** — View student profiles and their assessment results
4. **Messages** — Review and manage contact form submissions

## Database Schema

| Table | Description |
|-------|-------------|
| `users` | Student and admin accounts |
| `career_categories` | 8 career domains (Technology, Healthcare, Business, etc.) |
| `careers` | Individual career profiles within categories |
| `assessment_questions` | 15 multi-dimensional career questions |
| `assessment_options` | Answer choices linked to career categories |
| `user_assessments` | Assessment session tracking |
| `user_responses` | Individual question responses |
| `career_recommendations` | AI-generated career matches with scores |
| `counselor_notes` | Admin notes on student progress |
| `contact_messages` | Contact form submissions |

## License

This project is developed for Mount Kigali University (MKU) as part of an academic initiative.
