"""Flask REST API for Student Performance Prediction (predicting final grade G3)."""

import math
from pathlib import Path

import joblib
import pandas as pd
from flask import Flask, jsonify, request

# 1. Create the Flask application
app = Flask(__name__)

# 2. Locate and load the trained ML pipeline once when the server starts
BASE_DIR = Path(__file__).resolve().parent.parent
MODEL_PATH = BASE_DIR / "ml_model" / "student_model.pkl"
model = joblib.load(MODEL_PATH)

# 3. Exact 10 input features in the order expected by the trained model
EXPECTED_FEATURES = [
    "G1",
    "G2",
    "absences",
    "studytime",
    "failures",
    "age",
    "schoolsup",
    "activities",
    "internet",
    "higher",
]

# Validation rules for numeric and categorical fields
NUMERIC_RULES = {
    "G1": {"min": 0, "max": 20, "integer_only": False},
    "G2": {"min": 0, "max": 20, "integer_only": False},
    "absences": {"min": 0, "max": 365, "integer_only": True},
    "studytime": {"min": 1, "max": 4, "integer_only": True},
    "failures": {"min": 0, "max": 4, "integer_only": True},
    "age": {"min": 10, "max": 100, "integer_only": True},
}
CATEGORICAL_FEATURES = ["schoolsup", "activities", "internet", "higher"]
ALLOWED_YES_NO = {"yes", "no"}


def validate_student_payload(payload: object) -> tuple[dict | None, dict | None]:
    """Validate incoming JSON and return (cleaned_data, error_details)."""
    # Ensure the request body is a JSON object (dictionary)
    if not isinstance(payload, dict):
        return None, {
            "error": "Request body must be a JSON object containing the 10 student features."
        }

    # Check that all 10 required features are provided and not null
    missing = [
        feature
        for feature in EXPECTED_FEATURES
        if feature not in payload or payload[feature] is None
    ]
    if missing:
        return None, {
            "error": "Missing required features.",
            "missing_features": missing,
            "expected_features": EXPECTED_FEATURES,
        }

    cleaned = {}
    field_errors = {}

    # Validate numeric features (reject booleans, NaN/Inf, and out-of-range values)
    for feature, rules in NUMERIC_RULES.items():
        value = payload[feature]
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            field_errors[feature] = (
                f"Must be a number between {rules['min']} and {rules['max']}."
            )
            continue

        if math.isnan(value) or math.isinf(value):
            field_errors[feature] = "Must be a finite number."
            continue

        if rules["integer_only"] and not float(value).is_integer():
            field_errors[feature] = (
                f"Must be a whole number between {rules['min']} and {rules['max']}."
            )
            continue

        if value < rules["min"] or value > rules["max"]:
            field_errors[feature] = (
                f"Must be between {rules['min']} and {rules['max']}."
            )
            continue

        cleaned[feature] = int(value) if rules["integer_only"] else float(value)

    # Validate yes/no categorical features
    for feature in CATEGORICAL_FEATURES:
        value = payload[feature]
        if not isinstance(value, str):
            field_errors[feature] = "Must be a string: 'yes' or 'no'."
            continue

        normalized = value.strip().lower()
        if normalized not in ALLOWED_YES_NO:
            field_errors[feature] = "Must be either 'yes' or 'no'."
            continue

        cleaned[feature] = normalized

    if field_errors:
        return None, {
            "error": "Invalid input values.",
            "details": field_errors,
        }

    return cleaned, None


@app.after_request
def add_cors_headers(response):
    """Allow cross-origin requests (helpful for Flutter Web or local clients)."""
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type"
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    return response


@app.get("/health")
def health_check():
    """Return API health status to confirm the server and model are ready."""
    return (
        jsonify(
            {
                "status": "ok",
                "model_loaded": model is not None,
                "expected_features": EXPECTED_FEATURES,
            }
        ),
        200,
    )


@app.post("/predict")
def predict():
    """Validate student JSON input and return the predicted G3 grade (0 to 20)."""
    # Force silent=True so malformed JSON triggers our custom 400 message
    payload = request.get_json(silent=True)
    if payload is None:
        return (
            jsonify(
                {
                    "error": "Invalid or missing JSON body. Send JSON with Content-Type: application/json."
                }
            ),
            400,
        )

    cleaned_data, validation_error = validate_student_payload(payload)
    if validation_error is not None:
        return jsonify(validation_error), 400

    # Build a 1-row DataFrame with exact column names and order
    input_df = pd.DataFrame([cleaned_data], columns=EXPECTED_FEATURES)

    # Predict final grade G3 and clamp the result strictly between 0 and 20
    raw_prediction = float(model.predict(input_df)[0])
    clamped_prediction = max(0.0, min(20.0, raw_prediction))
    predicted_g3 = round(clamped_prediction, 2)

    return (
        jsonify(
            {
                "predicted_G3": predicted_g3,
                "scale": "0-20",
            }
        ),
        200,
    )


if __name__ == "__main__":
    # Start the local Flask development server on port 5000
    app.run(host="0.0.0.0", port=5000, debug=False)
