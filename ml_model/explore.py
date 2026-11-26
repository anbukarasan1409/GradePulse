
# Import required libraries
import pandas as pd
from pathlib import Path

# Get the main project directory
project_folder = Path(__file__).resolve().parent.parent

# Locate the dataset
dataset_path = project_folder / "dataset" / "student-mat.csv"

# Load the dataset
data = pd.read_csv(dataset_path, sep=";")

# Display first five records
print(data.head())

print("Dataset Shape:")
print(data.shape)


# Display dataset information
print("\nDATASET INFORMATION")
data.info()


# Display statistical summary
print("\nSTATISTICAL SUMMARY")
print(data.describe())

