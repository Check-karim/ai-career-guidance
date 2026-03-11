from flask_login import UserMixin
from app import mysql, login_manager


class User(UserMixin):
    def __init__(self, id, full_name, email, username, password_hash, role,
                 gender=None, date_of_birth=None, phone=None, faculty=None,
                 department=None, year_of_study=None, profile_picture=None,
                 created_at=None, updated_at=None):
        self.id = id
        self.full_name = full_name
        self.email = email
        self.username = username
        self.password_hash = password_hash
        self.role = role
        self.gender = gender
        self.date_of_birth = date_of_birth
        self.phone = phone
        self.faculty = faculty
        self.department = department
        self.year_of_study = year_of_study
        self.profile_picture = profile_picture
        self.created_at = created_at
        self.updated_at = updated_at

    @property
    def is_admin(self):
        return self.role == "admin"

    @staticmethod
    def get_by_id(user_id):
        cur = mysql.connection.cursor()
        cur.execute("SELECT * FROM users WHERE id = %s", (user_id,))
        row = cur.fetchone()
        cur.close()
        if row:
            return User(**row)
        return None

    @staticmethod
    def get_by_username(username):
        cur = mysql.connection.cursor()
        cur.execute("SELECT * FROM users WHERE username = %s", (username,))
        row = cur.fetchone()
        cur.close()
        if row:
            return User(**row)
        return None

    @staticmethod
    def get_by_email(email):
        cur = mysql.connection.cursor()
        cur.execute("SELECT * FROM users WHERE email = %s", (email,))
        row = cur.fetchone()
        cur.close()
        if row:
            return User(**row)
        return None

    @staticmethod
    def create(full_name, email, username, password_hash, role="user"):
        cur = mysql.connection.cursor()
        cur.execute(
            "INSERT INTO users (full_name, email, username, password_hash, role) "
            "VALUES (%s, %s, %s, %s, %s)",
            (full_name, email, username, password_hash, role),
        )
        mysql.connection.commit()
        user_id = cur.lastrowid
        cur.close()
        return user_id


@login_manager.user_loader
def load_user(user_id):
    return User.get_by_id(int(user_id))
