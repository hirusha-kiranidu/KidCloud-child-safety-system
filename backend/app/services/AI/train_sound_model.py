import pandas as pd
import librosa
import numpy as np
import os
from tqdm import tqdm
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
import pickle

# Load metadata
metadata = pd.read_csv("dataset/UrbanSound8K/metadata/UrbanSound8K.csv")

features = []
labels = []

def extract_features(file_path):
    audio, sample_rate = librosa.load(file_path, res_type='kaiser_fast')
    mfcc = librosa.feature.mfcc(y=audio, sr=sample_rate, n_mfcc=40)
    mfcc_scaled = np.mean(mfcc.T, axis=0)
    return mfcc_scaled

print("Extracting features from dataset...")

for index, row in tqdm(metadata.iterrows(), total=len(metadata)):
    
    file_path = os.path.join(
        "dataset/UrbanSound8K/audio/fold" + str(row["fold"]),
        row["slice_file_name"]
    )

    data = extract_features(file_path)

    features.append(data)
    labels.append(row["class"])

X = np.array(features)
y = np.array(labels)

print("Splitting dataset...")

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)


print("Training model...")

model = RandomForestClassifier(n_estimators=100)
model.fit(X_train, y_train)

accuracy = model.score(X_test, y_test)

print("Model Accuracy:", accuracy)

# Save model
os.makedirs("models", exist_ok=True)

with open("models/sound_model.pkl", "wb") as f:
    pickle.dump(model, f)

print("Model saved to models/sound_model.pkl")