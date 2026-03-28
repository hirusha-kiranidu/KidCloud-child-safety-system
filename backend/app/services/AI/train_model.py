import os
import numpy as np
import librosa
import pickle
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder

DATASET_PATH = "dataset"

features = []
labels = []

def extract_features(file_path):
    audio, sample_rate = librosa.load(file_path, res_type='kaiser_fast')
    
    mfcc = librosa.feature.mfcc(y=audio, sr=sample_rate, n_mfcc=60)
    mfcc_scaled = np.hstack([
    np.mean(mfcc, axis=1),
    np.std(mfcc, axis=1)
    ])
    
    return mfcc_scaled

print(" Loading dataset...")

for label in os.listdir(DATASET_PATH):
    
    folder_path = os.path.join(DATASET_PATH, label)

    if os.path.isdir(folder_path):
        for file in os.listdir(folder_path):
            if file.endswith(".wav"):
                file_path = os.path.join(folder_path, file)
                
                try:
                    data = extract_features(file_path)
                    features.append(data)
                    labels.append(label)
                except:
                    print("Error processing:", file_path)

print("Dataset loaded!")

X = np.array(features)
y = np.array(labels)

# Encode labels
encoder = LabelEncoder()
y_encoded = encoder.fit_transform(y)

# Split dataset
X_train, X_test, y_train, y_test = train_test_split(
    X, y_encoded, test_size=0.2, random_state=42
)

print(" Training model...")

model = RandomForestClassifier(n_estimators=200, max_depth=20, class_weight="balanced")
model.fit(X_train, y_train)

accuracy = model.score(X_test, y_test)

print(" Model trained!")
print(" Accuracy:", accuracy)

# Save model + encoder
os.makedirs("models", exist_ok=True)

pickle.dump(model, open("models/sound_model.pkl", "wb"))
pickle.dump(encoder, open("models/label_encoder.pkl", "wb"))

print(" Model saved in models/")


from sklearn.metrics import classification_report, confusion_matrix

# Predict on test data
y_pred = model.predict(X_test)

print("\n===== MODEL EVALUATION =====")

print("\nClassification Report:")
print(classification_report(y_test, y_pred))

print("\nConfusion Matrix:")
print(confusion_matrix(y_test, y_pred))