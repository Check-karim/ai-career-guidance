from functools import wraps
from flask import Blueprint, render_template, redirect, url_for, flash
from flask_login import login_required, current_user
from app import mysql

admin_bp = Blueprint("admin", __name__)


def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not current_user.is_authenticated or not current_user.is_admin:
            flash("Access denied. Admin privileges required.", "danger")
            return redirect(url_for("main.home"))
        return f(*args, **kwargs)
    return decorated_function


@admin_bp.route("/dashboard")
@login_required
@admin_required
def dashboard():
    cur = mysql.connection.cursor()

    cur.execute("SELECT COUNT(*) as count FROM users WHERE role = 'user'")
    total_users = cur.fetchone()["count"]

    cur.execute("SELECT COUNT(*) as count FROM user_assessments WHERE status = 'completed'")
    total_assessments = cur.fetchone()["count"]

    cur.execute("SELECT COUNT(*) as count FROM career_recommendations")
    total_recommendations = cur.fetchone()["count"]

    cur.execute("SELECT COUNT(*) as count FROM contact_messages WHERE is_read = 0")
    unread_messages = cur.fetchone()["count"]

    cur.execute(
        "SELECT u.id, u.full_name, u.email, u.username, u.faculty, u.created_at "
        "FROM users u WHERE u.role = 'user' ORDER BY u.created_at DESC LIMIT 10"
    )
    recent_users = cur.fetchall()

    cur.execute(
        "SELECT cm.*, CASE WHEN cm.is_read = 0 THEN 'Unread' ELSE 'Read' END as status "
        "FROM contact_messages cm ORDER BY cm.created_at DESC LIMIT 5"
    )
    recent_messages = cur.fetchall()

    cur.close()

    return render_template(
        "admin/dashboard.html",
        total_users=total_users,
        total_assessments=total_assessments,
        total_recommendations=total_recommendations,
        unread_messages=unread_messages,
        recent_users=recent_users,
        recent_messages=recent_messages,
    )


@admin_bp.route("/users")
@login_required
@admin_required
def users():
    cur = mysql.connection.cursor()
    cur.execute(
        "SELECT u.*, "
        "(SELECT COUNT(*) FROM user_assessments ua WHERE ua.user_id = u.id AND ua.status = 'completed') as assessments_count "
        "FROM users u WHERE u.role = 'user' ORDER BY u.created_at DESC"
    )
    all_users = cur.fetchall()
    cur.close()
    return render_template("admin/users.html", users=all_users)


@admin_bp.route("/users/<int:user_id>")
@login_required
@admin_required
def user_detail(user_id):
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM users WHERE id = %s", (user_id,))
    user = cur.fetchone()

    if not user:
        flash("User not found.", "danger")
        return redirect(url_for("admin.users"))

    cur.execute(
        "SELECT ua.*, "
        "(SELECT COUNT(*) FROM career_recommendations cr WHERE cr.assessment_id = ua.id) as recommendations_count "
        "FROM user_assessments ua WHERE ua.user_id = %s ORDER BY ua.started_at DESC",
        (user_id,),
    )
    assessments = cur.fetchall()

    cur.execute(
        "SELECT cr.*, c.title as career_title, cc.name as category_name "
        "FROM career_recommendations cr "
        "JOIN careers c ON cr.career_id = c.id "
        "JOIN career_categories cc ON c.category_id = cc.id "
        "WHERE cr.user_id = %s ORDER BY cr.match_score DESC",
        (user_id,),
    )
    recommendations = cur.fetchall()

    cur.close()
    return render_template(
        "admin/user_detail.html",
        user=user,
        assessments=assessments,
        recommendations=recommendations,
    )


@admin_bp.route("/messages")
@login_required
@admin_required
def messages():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM contact_messages ORDER BY created_at DESC")
    all_messages = cur.fetchall()
    cur.close()
    return render_template("admin/messages.html", messages=all_messages)


@admin_bp.route("/messages/<int:message_id>/read")
@login_required
@admin_required
def mark_message_read(message_id):
    cur = mysql.connection.cursor()
    cur.execute("UPDATE contact_messages SET is_read = 1 WHERE id = %s", (message_id,))
    mysql.connection.commit()
    cur.close()
    flash("Message marked as read.", "success")
    return redirect(url_for("admin.messages"))
