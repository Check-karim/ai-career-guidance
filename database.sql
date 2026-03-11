-- ============================================
-- AI Career Guidance System - Database Schema
-- Mount Kigali University (MKU)
-- ============================================

CREATE DATABASE IF NOT EXISTS ai_career_guidance;
USE ai_career_guidance;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    username VARCHAR(80) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('user', 'admin') DEFAULT 'user',
    gender ENUM('male', 'female', 'other') NULL,
    date_of_birth DATE NULL,
    phone VARCHAR(20) NULL,
    faculty VARCHAR(150) NULL,
    department VARCHAR(150) NULL,
    year_of_study INT NULL,
    profile_picture VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Career categories
CREATE TABLE IF NOT EXISTS career_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Careers
CREATE TABLE IF NOT EXISTS careers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    required_skills TEXT,
    education_path TEXT,
    salary_range VARCHAR(100) NULL,
    job_outlook VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES career_categories(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Assessment questions
CREATE TABLE IF NOT EXISTS assessment_questions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question_text TEXT NOT NULL,
    question_type ENUM('interest', 'skill', 'personality', 'academic') NOT NULL,
    category VARCHAR(100) NOT NULL,
    weight INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Assessment options (answers for each question)
CREATE TABLE IF NOT EXISTS assessment_options (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT NOT NULL,
    option_text VARCHAR(255) NOT NULL,
    score INT DEFAULT 0,
    career_category_id INT NULL,
    FOREIGN KEY (question_id) REFERENCES assessment_questions(id) ON DELETE CASCADE,
    FOREIGN KEY (career_category_id) REFERENCES career_categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- User assessments (tracks when a user takes an assessment)
CREATE TABLE IF NOT EXISTS user_assessments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    status ENUM('in_progress', 'completed') DEFAULT 'in_progress',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- User responses (individual answers)
CREATE TABLE IF NOT EXISTS user_responses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    assessment_id INT NOT NULL,
    question_id INT NOT NULL,
    option_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (assessment_id) REFERENCES user_assessments(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES assessment_questions(id) ON DELETE CASCADE,
    FOREIGN KEY (option_id) REFERENCES assessment_options(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Career recommendations
CREATE TABLE IF NOT EXISTS career_recommendations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    assessment_id INT NOT NULL,
    user_id INT NOT NULL,
    career_id INT NOT NULL,
    match_score DECIMAL(5,2) NOT NULL,
    reasoning TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (assessment_id) REFERENCES user_assessments(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (career_id) REFERENCES careers(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Counselor notes
CREATE TABLE IF NOT EXISTS counselor_notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    admin_id INT NOT NULL,
    note_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Contact messages
CREATE TABLE IF NOT EXISTS contact_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- Seed Data
-- ============================================

-- Insert admin user (password: admin) - bcrypt hash
INSERT INTO users (full_name, email, username, password_hash, role) VALUES
('System Administrator', 'admin@mku.ac.rw', 'admin', '$2b$12$WJ411msDsjcPqESwbTN4NOyqWad1jijhSq22IkV7TsFPzPLOGgZme', 'admin');

-- Insert career categories
INSERT INTO career_categories (name, description, icon) VALUES
('Technology & Computing', 'Careers in software development, data science, cybersecurity, and IT management.', 'fa-laptop-code'),
('Healthcare & Medicine', 'Careers in medicine, nursing, pharmacy, public health, and biomedical sciences.', 'fa-heartbeat'),
('Business & Finance', 'Careers in accounting, banking, entrepreneurship, marketing, and management.', 'fa-chart-line'),
('Engineering', 'Careers in civil, mechanical, electrical, and environmental engineering.', 'fa-cogs'),
('Education & Training', 'Careers in teaching, educational administration, and academic research.', 'fa-graduation-cap'),
('Arts & Creative Design', 'Careers in graphic design, multimedia, music, fine arts, and creative writing.', 'fa-palette'),
('Law & Governance', 'Careers in law, public administration, diplomacy, and international relations.', 'fa-gavel'),
('Science & Research', 'Careers in biology, chemistry, physics, environmental science, and research.', 'fa-flask');

-- Insert careers
INSERT INTO careers (category_id, title, description, required_skills, education_path, salary_range, job_outlook) VALUES
(1, 'Software Developer', 'Design, build, and maintain software applications and systems.', 'Programming, Problem-solving, Algorithms, Team collaboration', 'BSc Computer Science or Software Engineering', '$50,000 - $120,000', 'Very High Demand'),
(1, 'Data Scientist', 'Analyze complex data to help organizations make better decisions.', 'Statistics, Machine Learning, Python/R, Data Visualization', 'BSc/MSc in Data Science, Statistics, or Computer Science', '$60,000 - $130,000', 'Very High Demand'),
(1, 'Cybersecurity Analyst', 'Protect computer systems and networks from cyber threats.', 'Network Security, Ethical Hacking, Risk Assessment', 'BSc Computer Science + Security Certifications', '$55,000 - $110,000', 'High Demand'),
(2, 'Medical Doctor', 'Diagnose and treat illnesses, injuries, and other health conditions.', 'Clinical Skills, Empathy, Critical Thinking, Communication', 'MBBS/MD + Residency', '$60,000 - $200,000+', 'High Demand'),
(2, 'Pharmacist', 'Dispense medications and advise patients on proper drug usage.', 'Pharmaceutical Knowledge, Attention to Detail, Communication', 'PharmD or BPharm', '$45,000 - $90,000', 'Steady Demand'),
(3, 'Financial Analyst', 'Evaluate financial data to guide business investment decisions.', 'Financial Modeling, Excel, Analytical Thinking, Communication', 'BSc Finance, Accounting, or Economics', '$50,000 - $100,000', 'High Demand'),
(3, 'Marketing Manager', 'Develop strategies to promote products and grow brand awareness.', 'Creativity, Digital Marketing, Analytics, Leadership', 'BSc Marketing or Business Administration', '$45,000 - $95,000', 'High Demand'),
(4, 'Civil Engineer', 'Design and supervise construction of infrastructure projects.', 'Mathematics, CAD Software, Project Management, Physics', 'BSc Civil Engineering', '$50,000 - $100,000', 'Steady Demand'),
(5, 'University Lecturer', 'Teach and conduct research at higher education institutions.', 'Subject Expertise, Research, Communication, Mentoring', 'MSc/PhD in relevant field', '$40,000 - $80,000', 'Steady Demand'),
(6, 'Graphic Designer', 'Create visual content for digital and print media.', 'Adobe Creative Suite, Creativity, Typography, Color Theory', 'BSc/Diploma in Graphic Design or Fine Arts', '$35,000 - $70,000', 'Moderate Demand'),
(7, 'Lawyer', 'Represent clients in legal matters and provide legal counsel.', 'Legal Research, Argumentation, Critical Thinking, Writing', 'LLB + Bar Admission', '$45,000 - $120,000', 'Steady Demand'),
(8, 'Research Scientist', 'Conduct experiments and research to advance scientific knowledge.', 'Research Methods, Data Analysis, Scientific Writing, Lab Skills', 'MSc/PhD in relevant science field', '$45,000 - $95,000', 'Moderate Demand');

-- Insert assessment questions
INSERT INTO assessment_questions (question_text, question_type, category, weight) VALUES
('How interested are you in solving complex mathematical or logical problems?', 'interest', 'analytical', 2),
('Do you enjoy working with computers and technology?', 'interest', 'technology', 2),
('How much do you enjoy helping and caring for other people?', 'interest', 'social', 2),
('Are you interested in understanding how businesses and markets work?', 'interest', 'business', 2),
('Do you enjoy creative activities like drawing, writing, or designing?', 'interest', 'creative', 2),
('How comfortable are you with public speaking and presentations?', 'skill', 'communication', 1),
('Rate your ability to work effectively in a team.', 'skill', 'teamwork', 1),
('How strong are your analytical and critical thinking skills?', 'skill', 'analytical', 2),
('Do you prefer working independently or in a structured environment?', 'personality', 'work_style', 1),
('How do you handle stressful situations and tight deadlines?', 'personality', 'resilience', 1),
('What is your strongest academic subject area?', 'academic', 'strength', 2),
('How interested are you in conducting research and experiments?', 'interest', 'research', 2),
('Do you enjoy debating, arguing cases, or persuading others?', 'interest', 'advocacy', 1),
('Are you passionate about teaching and mentoring others?', 'interest', 'education', 1),
('How interested are you in building or constructing things?', 'interest', 'engineering', 2);

-- Insert assessment options for each question
-- Q1: Mathematical/logical problems
INSERT INTO assessment_options (question_id, option_text, score, career_category_id) VALUES
(1, 'Very interested - I love puzzles and logic', 5, 1),
(1, 'Somewhat interested', 3, 4),
(1, 'Neutral', 2, NULL),
(1, 'Not very interested', 1, 6),
(1, 'Not at all interested', 0, NULL);

-- Q2: Computers and technology
INSERT INTO assessment_options (question_id, option_text, score, career_category_id) VALUES
(2, 'Very interested - I love tech', 5, 1),
(2, 'Somewhat interested', 3, 1),
(2, 'Neutral', 2, NULL),
(2, 'Not very interested', 1, NULL),
(2, 'Not at all interested', 0, NULL);

-- Q3: Helping and caring for people
INSERT INTO assessment_options (question_id, option_text, score, career_category_id) VALUES
(3, 'Very much - I am deeply empathetic', 5, 2),
(3, 'Somewhat', 3, 5),
(3, 'Neutral', 2, NULL),
(3, 'Not much', 1, NULL),
(3, 'Not at all', 0, NULL);

-- Q4: Business and markets
INSERT INTO assessment_options (question_id, option_text, score, career_category_id) VALUES
(4, 'Very interested', 5, 3),
(4, 'Somewhat interested', 3, 3),
(4, 'Neutral', 2, NULL),
(4, 'Not very interested', 1, NULL),
(4, 'Not at all interested', 0, NULL);

-- Q5: Creative activities
INSERT INTO assessment_options (question_id, option_text, score, career_category_id) VALUES
(5, 'Very much - creativity is my strength', 5, 6),
(5, 'Somewhat', 3, 6),
(5, 'Neutral', 2, NULL),
(5, 'Not much', 1, NULL),
(5, 'Not at all', 0, NULL);

-- Q6: Public speaking
INSERT INTO assessment_options (question_id, option_text, score, career_category_id) VALUES
(6, 'Very comfortable', 5, 7),
(6, 'Somewhat comfortable', 3, 3),
(6, 'Neutral', 2, NULL),
(6, 'Uncomfortable', 1, NULL),
(6, 'Very uncomfortable', 0, NULL);

-- Q7: Teamwork
INSERT INTO assessment_options (question_id, option_text, score, career_category_id) VALUES
(7, 'Excellent team player', 5, 3),
(7, 'Good at teamwork', 3, 4),
(7, 'Average', 2, NULL),
(7, 'Prefer working alone', 1, 8),
(7, 'Strongly prefer solo work', 0, 8);

-- Q8: Analytical thinking
INSERT INTO assessment_options (question_id, option_text, score, career_category_id) VALUES
(8, 'Very strong', 5, 1),
(8, 'Strong', 4, 8),
(8, 'Average', 2, NULL),
(8, 'Below average', 1, NULL),
(8, 'Weak', 0, NULL);

-- Q9: Work style
INSERT INTO assessment_options (question_id, option_text, score, career_category_id) VALUES
(9, 'Strongly prefer independence', 5, 8),
(9, 'Prefer independence with some structure', 4, 1),
(9, 'Balance of both', 3, NULL),
(9, 'Prefer structured environment', 2, 3),
(9, 'Strongly prefer structured environment', 1, 2);

-- Q10: Stress handling
INSERT INTO assessment_options (question_id, option_text, score, career_category_id) VALUES
(10, 'I thrive under pressure', 5, 2),
(10, 'I handle it well', 4, 7),
(10, 'I manage adequately', 3, NULL),
(10, 'I struggle sometimes', 2, 5),
(10, 'I find it very difficult', 1, NULL);

-- Q11: Academic strength
INSERT INTO assessment_options (question_id, option_text, score, career_category_id) VALUES
(11, 'Mathematics and Sciences', 5, 4),
(11, 'Computer Science and IT', 5, 1),
(11, 'Languages and Humanities', 4, 5),
(11, 'Business and Economics', 4, 3),
(11, 'Arts and Design', 4, 6);

-- Q12: Research and experiments
INSERT INTO assessment_options (question_id, option_text, score, career_category_id) VALUES
(12, 'Very interested', 5, 8),
(12, 'Somewhat interested', 3, 8),
(12, 'Neutral', 2, NULL),
(12, 'Not very interested', 1, NULL),
(12, 'Not at all interested', 0, NULL);

-- Q13: Debating and persuading
INSERT INTO assessment_options (question_id, option_text, score, career_category_id) VALUES
(13, 'I love debating', 5, 7),
(13, 'I enjoy it sometimes', 3, 7),
(13, 'Neutral', 2, NULL),
(13, 'I avoid it', 1, NULL),
(13, 'I strongly dislike it', 0, NULL);

-- Q14: Teaching and mentoring
INSERT INTO assessment_options (question_id, option_text, score, career_category_id) VALUES
(14, 'Very passionate', 5, 5),
(14, 'Somewhat passionate', 3, 5),
(14, 'Neutral', 2, NULL),
(14, 'Not interested', 1, NULL),
(14, 'Not at all', 0, NULL);

-- Q15: Building/constructing
INSERT INTO assessment_options (question_id, option_text, score, career_category_id) VALUES
(15, 'Very interested', 5, 4),
(15, 'Somewhat interested', 3, 4),
(15, 'Neutral', 2, NULL),
(15, 'Not very interested', 1, NULL),
(15, 'Not at all interested', 0, NULL);
