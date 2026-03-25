import re

from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_user, logout_user, login_required, current_user
from app import bcrypt
from app.models import User

auth_bp = Blueprint("auth", __name__)


@auth_bp.route("/login", methods=["GET", "POST"])
def login():
    if current_user.is_authenticated:
        if current_user.is_admin:
            return redirect(url_for("admin.dashboard"))
        return redirect(url_for("career.dashboard"))

    if request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")

        if not username or not password:
            flash("Please enter both username and password.", "danger")
            return redirect(url_for("auth.login"))

        user = User.get_by_username(username)
        if user and bcrypt.check_password_hash(user.password_hash, password):
            login_user(user)
            next_page = request.args.get("next")
            flash(f"Welcome back, {user.full_name}!", "success")
            if user.is_admin:
                return redirect(next_page or url_for("admin.dashboard"))
            return redirect(next_page or url_for("career.dashboard"))
        else:
            flash("Invalid username or password.", "danger")

    return render_template("login.html")


@auth_bp.route("/register", methods=["GET", "POST"])
def register():
    if current_user.is_authenticated:
        return redirect(url_for("career.dashboard"))

    if request.method == "POST":
        full_name = request.form.get("full_name")
        email = request.form.get("email")
        username = request.form.get("username")
        password = request.form.get("password")
        confirm_password = request.form.get("confirm_password")

        if not all([full_name, email, username, password, confirm_password]):
            flash("Please fill in all fields.", "danger")
            return redirect(url_for("auth.register"))

        if re.search(r'\d', full_name):
            flash("Full name must not contain numbers.", "danger")
            return redirect(url_for("auth.register"))

        email_regex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(email_regex, email):
            flash("Please enter a valid email address.", "danger")
            return redirect(url_for("auth.register"))

        if ' ' in username:
            flash("Username must not contain spaces.", "danger")
            return redirect(url_for("auth.register"))

        if username[0].isdigit():
            flash("Username must not start with a number.", "danger")
            return redirect(url_for("auth.register"))

        if len(password) < 6:
            flash("Password must be at least 6 characters long.", "danger")
            return redirect(url_for("auth.register"))

        if password != confirm_password:
            flash("Passwords do not match.", "danger")
            return redirect(url_for("auth.register"))

        if User.get_by_username(username):
            flash("Username already taken.", "danger")
            return redirect(url_for("auth.register"))

        if User.get_by_email(email):
            flash("Email already registered.", "danger")
            return redirect(url_for("auth.register"))

        hashed_pw = bcrypt.generate_password_hash(password).decode("utf-8")
        User.create(full_name, email, username, hashed_pw)

        flash("Account created successfully! Please log in.", "success")
        return redirect(url_for("auth.login"))

    return render_template("register.html")


@auth_bp.route("/logout")
@login_required
def logout():
    logout_user()
    flash("You have been logged out.", "info")
    return redirect(url_for("main.home"))
