document.addEventListener("DOMContentLoaded", function () {
    // Mobile nav toggle
    const navToggle = document.getElementById("navToggle");
    const navMenu = document.getElementById("navMenu");

    if (navToggle) {
        navToggle.addEventListener("click", function () {
            navToggle.classList.toggle("active");
            navMenu.classList.toggle("active");
        });

        document.addEventListener("click", function (e) {
            if (!navToggle.contains(e.target) && !navMenu.contains(e.target)) {
                navToggle.classList.remove("active");
                navMenu.classList.remove("active");
            }
        });
    }

    // Navbar scroll effect
    const navbar = document.getElementById("navbar");
    window.addEventListener("scroll", function () {
        if (window.scrollY > 50) {
            navbar.classList.add("scrolled");
        } else {
            navbar.classList.remove("scrolled");
        }
    });

    // Auto-dismiss flash messages
    const flashMessages = document.querySelectorAll(".flash-message");
    flashMessages.forEach(function (msg) {
        setTimeout(function () {
            msg.style.opacity = "0";
            msg.style.transform = "translateY(-20px)";
            setTimeout(function () {
                msg.remove();
            }, 300);
        }, 5000);
    });

    // Assessment progress bar
    const assessmentForm = document.getElementById("assessmentForm");
    if (assessmentForm) {
        const questions = assessmentForm.querySelectorAll(".question-block");
        const progressBar = document.getElementById("progressBar");
        const totalQuestions = questions.length;

        assessmentForm.addEventListener("change", function () {
            const answered = assessmentForm.querySelectorAll(
                'input[type="radio"]:checked'
            ).length;
            const percent = (answered / totalQuestions) * 100;
            if (progressBar) {
                progressBar.style.width = percent + "%";
            }
        });

        assessmentForm.addEventListener("submit", function (e) {
            const answered = assessmentForm.querySelectorAll(
                'input[type="radio"]:checked'
            ).length;
            if (answered < totalQuestions) {
                e.preventDefault();
                alert(
                    "Please answer all " +
                        totalQuestions +
                        " questions before submitting. You have answered " +
                        answered +
                        " so far."
                );
            }
        });
    }

    // Scroll reveal animation
    const observerOptions = {
        threshold: 0.1,
        rootMargin: "0px 0px -50px 0px",
    };

    const observer = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
            if (entry.isIntersecting) {
                entry.target.classList.add("revealed");
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    document.querySelectorAll(".feature-card, .step-card, .value-card, .stat-card, .recommendation-card").forEach(function (el) {
        el.style.opacity = "0";
        el.style.transform = "translateY(20px)";
        el.style.transition = "opacity 0.5s ease, transform 0.5s ease";
        observer.observe(el);
    });

    // Add revealed styles
    const style = document.createElement("style");
    style.textContent = ".revealed { opacity: 1 !important; transform: translateY(0) !important; }";
    document.head.appendChild(style);
});
