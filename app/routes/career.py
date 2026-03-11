from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_required, current_user
from app import mysql
from collections import defaultdict

career_bp = Blueprint("career", __name__)


@career_bp.route("/dashboard")
@login_required
def dashboard():
    cur = mysql.connection.cursor()

    cur.execute(
        "SELECT COUNT(*) as count FROM user_assessments "
        "WHERE user_id = %s AND status = 'completed'",
        (current_user.id,),
    )
    completed_assessments = cur.fetchone()["count"]

    cur.execute(
        "SELECT cr.*, c.title as career_title, cc.name as category_name, cc.icon "
        "FROM career_recommendations cr "
        "JOIN careers c ON cr.career_id = c.id "
        "JOIN career_categories cc ON c.category_id = cc.id "
        "WHERE cr.user_id = %s ORDER BY cr.match_score DESC LIMIT 3",
        (current_user.id,),
    )
    top_recommendations = cur.fetchall()

    cur.close()
    return render_template(
        "career/dashboard.html",
        completed_assessments=completed_assessments,
        top_recommendations=top_recommendations,
    )


@career_bp.route("/assessment")
@login_required
def assessment():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM assessment_questions ORDER BY id")
    questions = cur.fetchall()

    for q in questions:
        cur.execute(
            "SELECT * FROM assessment_options WHERE question_id = %s ORDER BY id",
            (q["id"],),
        )
        q["options"] = cur.fetchall()

    cur.close()
    return render_template("career/assessment.html", questions=questions)


@career_bp.route("/assessment/submit", methods=["POST"])
@login_required
def submit_assessment():
    cur = mysql.connection.cursor()

    cur.execute(
        "INSERT INTO user_assessments (user_id, status) VALUES (%s, 'in_progress')",
        (current_user.id,),
    )
    mysql.connection.commit()
    assessment_id = cur.lastrowid

    cur.execute("SELECT * FROM assessment_questions ORDER BY id")
    questions = cur.fetchall()

    category_scores = defaultdict(float)
    category_max = defaultdict(float)

    for question in questions:
        answer_key = f"question_{question['id']}"
        option_id = request.form.get(answer_key)

        if option_id:
            option_id = int(option_id)
            cur.execute(
                "INSERT INTO user_responses (assessment_id, question_id, option_id) "
                "VALUES (%s, %s, %s)",
                (assessment_id, question["id"], option_id),
            )

            cur.execute("SELECT * FROM assessment_options WHERE id = %s", (option_id,))
            option = cur.fetchone()

            if option and option["career_category_id"]:
                weight = question["weight"]
                category_scores[option["career_category_id"]] += option["score"] * weight

            cur.execute(
                "SELECT DISTINCT career_category_id FROM assessment_options "
                "WHERE question_id = %s AND career_category_id IS NOT NULL",
                (question["id"],),
            )
            for cat_row in cur.fetchall():
                cat_id = cat_row["career_category_id"]
                category_max[cat_id] += 5 * question["weight"]

    cur.execute(
        "UPDATE user_assessments SET status = 'completed', completed_at = NOW() "
        "WHERE id = %s",
        (assessment_id,),
    )

    ranked_categories = []
    for cat_id, score in category_scores.items():
        max_score = category_max.get(cat_id, 1)
        percentage = (score / max_score) * 100 if max_score > 0 else 0
        ranked_categories.append((cat_id, percentage))

    ranked_categories.sort(key=lambda x: x[1], reverse=True)

    for cat_id, percentage in ranked_categories[:3]:
        cur.execute(
            "SELECT * FROM careers WHERE category_id = %s ORDER BY id LIMIT 1",
            (cat_id,),
        )
        career = cur.fetchone()

        if career:
            reasoning = generate_reasoning(cur, cat_id, percentage)
            cur.execute(
                "INSERT INTO career_recommendations "
                "(assessment_id, user_id, career_id, match_score, reasoning) "
                "VALUES (%s, %s, %s, %s, %s)",
                (assessment_id, current_user.id, career["id"], round(percentage, 2), reasoning),
            )

    mysql.connection.commit()
    cur.close()

    flash("Assessment completed! View your career recommendations below.", "success")
    return redirect(url_for("career.results", assessment_id=assessment_id))


def generate_reasoning(cur, category_id, score):
    cur.execute("SELECT name FROM career_categories WHERE id = %s", (category_id,))
    category = cur.fetchone()
    cat_name = category["name"] if category else "this field"

    if score >= 80:
        strength = "an excellent"
    elif score >= 60:
        strength = "a strong"
    elif score >= 40:
        strength = "a moderate"
    else:
        strength = "some"

    return (
        f"Based on your assessment responses, you show {strength} alignment "
        f"with {cat_name}. Your interests, skills, and personality traits "
        f"suggest you would thrive in careers within this domain. "
        f"We recommend exploring specific roles and educational pathways "
        f"in this area to find the best fit for your unique profile."
    )


@career_bp.route("/results/<int:assessment_id>")
@login_required
def results(assessment_id):
    cur = mysql.connection.cursor()

    cur.execute(
        "SELECT * FROM user_assessments WHERE id = %s AND user_id = %s",
        (assessment_id, current_user.id),
    )
    assessment = cur.fetchone()

    if not assessment:
        flash("Assessment not found.", "danger")
        return redirect(url_for("career.dashboard"))

    cur.execute(
        "SELECT cr.*, c.title as career_title, c.description as career_description, "
        "c.required_skills, c.education_path, c.salary_range, c.job_outlook, "
        "cc.name as category_name, cc.icon "
        "FROM career_recommendations cr "
        "JOIN careers c ON cr.career_id = c.id "
        "JOIN career_categories cc ON c.category_id = cc.id "
        "WHERE cr.assessment_id = %s ORDER BY cr.match_score DESC",
        (assessment_id,),
    )
    recommendations = cur.fetchall()
    cur.close()

    return render_template(
        "career/results.html",
        assessment=assessment,
        recommendations=recommendations,
    )


@career_bp.route("/history")
@login_required
def history():
    cur = mysql.connection.cursor()
    cur.execute(
        "SELECT ua.*, "
        "(SELECT COUNT(*) FROM career_recommendations cr WHERE cr.assessment_id = ua.id) as rec_count "
        "FROM user_assessments ua "
        "WHERE ua.user_id = %s ORDER BY ua.started_at DESC",
        (current_user.id,),
    )
    assessments = cur.fetchall()
    cur.close()
    return render_template("career/history.html", assessments=assessments)


@career_bp.route("/explore")
@login_required
def explore():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM career_categories ORDER BY name")
    categories = cur.fetchall()

    for cat in categories:
        cur.execute(
            "SELECT * FROM careers WHERE category_id = %s ORDER BY title",
            (cat["id"],),
        )
        cat["careers"] = cur.fetchall()

    cur.close()
    return render_template("career/explore.html", categories=categories)
