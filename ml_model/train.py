"""Train a Random Forest Regression model to predict student final grades (G3)."""

from pathlib import Path
import joblib
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestRegressor
from sklearn.impute import SimpleImputer
from sklearn.metrics import mean_absolute_error, r2_score, root_mean_squared_error
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder

# 1. Set up project file paths relative to this script
BASE_DIR = Path(__file__).resolve().parent.parent
DATA_PATH = BASE_DIR / "dataset" / "student-mat.csv"
MODEL_PATH = BASE_DIR / "ml_model" / "student_model.pkl"

# 2. Define the exact 10 input features and target column
SELECTED_FEATURES = [
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
TARGET_COLUMN = "G3"


def main() -> None:
    # 3. Load the semicolon-separated Math dataset
    data = pd.read_csv(DATA_PATH, sep=";")

    # 4. Separate the 10 selected input features (X) and target grade (y)
    X = data[SELECTED_FEATURES]
    y = data[TARGET_COLUMN]

    # Identify numeric vs. categorical (text) columns automatically
    numerical_cols = X.select_dtypes(include=["number"]).columns.tolist()
    categorical_cols = X.select_dtypes(exclude=["number"]).columns.tolist()

    # 5. Build preprocessing steps for numeric and categorical inputs
    numeric_transformer = Pipeline([
        ("imputer", SimpleImputer(strategy="median")),
    ])

    categorical_transformer = Pipeline([
        ("imputer", SimpleImputer(strategy="most_frequent")),
        ("encoder", OneHotEncoder(handle_unknown="ignore")),
    ])

    preprocessor = ColumnTransformer([
        ("num", numeric_transformer, numerical_cols),
        ("cat", categorical_transformer, categorical_cols),
    ])

    # 6. Combine preprocessing and Random Forest Regressor into one Pipeline
    model = Pipeline([
        ("preprocessing", preprocessor),
        (
            "regressor",
            RandomForestRegressor(
                n_estimators=200,
                random_state=42,
            ),
        ),
    ])

    # 7. Split data into 80% training and 20% testing sets
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    # 8. Train the pipeline on the training set
    print("Training Random Forest Regressor...")
    model.fit(X_train, y_train)

    # 9. Evaluate predictions on the unseen test set
    predictions = model.predict(X_test)
    mae = mean_absolute_error(y_test, predictions)
    rmse = root_mean_squared_error(y_test, predictions)
    r2 = r2_score(y_test, predictions)

    print("\nSELECTED FEATURES (10):")
    print(", ".join(SELECTED_FEATURES))
    print(f"Numerical features ({len(numerical_cols)}): {numerical_cols}")
    print(f"Categorical features ({len(categorical_cols)}): {categorical_cols}")

    print("\nMODEL EVALUATION")
    print(f"MAE:      {mae:.4f}")
    print(f"RMSE:     {rmse:.4f}")
    print(f"R2 Score: {r2:.4f}")

    # 10. Save the complete fitted pipeline (preprocessing + model)
    joblib.dump(model, MODEL_PATH)
    print(f"\nModel saved successfully to: {MODEL_PATH}")


if __name__ == "__main__":
    main()
