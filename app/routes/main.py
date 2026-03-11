from flask import Blueprint, render_template, request, flash, redirect, url_for
from app import mysql

main_bp = Blueprint("main", __name__)


@main_bp.route("/")
def home():
    return render_template("home.html")


@main_bp.route("/about")
def about():
    return render_template("about.html")


@main_bp.route("/contact", methods=["GET", "POST"])
def contact():
    if request.method == "POST":
        name = request.form.get("name")
        email = request.form.get("email")
        subject = request.form.get("subject")
        message = request.form.get("message")

        if not all([name, email, subject, message]):
            flash("Please fill in all fields.", "danger")
            return redirect(url_for("main.contact"))

        cur = mysql.connection.cursor()
        cur.execute(
            "INSERT INTO contact_messages (name, email, subject, message) "
            "VALUES (%s, %s, %s, %s)",
            (name, email, subject, message),
        )
        mysql.connection.commit()
        cur.close()

        flash("Your message has been sent successfully!", "success")
        return redirect(url_for("main.contact"))

    return render_template("contact.html")
