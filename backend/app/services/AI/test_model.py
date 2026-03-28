import os
import librosa
import numpy as np
import pickle

# Load model
model = pickle.load(open("models/sound_model.pkl", "rb"))
encoder = pickle.load(open("models/label_encoder.pkl", "rb"))

def extract_features(file_path):
    audio, sample_rate = librosa.load(file_path, res_type='kaiser_fast')
    mfcc = librosa.feature.mfcc(y=audio, sr=sample_rate, n_mfcc=60)

    features = np.hstack([
        np.mean(mfcc, axis=1),
        np.std(mfcc, axis=1)
    ])

    return features.reshape(1, -1)

# Test folder
test_folder = "test_sounds"

correct = 0
total = 0

for label in os.listdir(test_folder):
    label_path = os.path.join(test_folder, label)

    for file in os.listdir(label_path):
        file_path = os.path.join(label_path, file)

        features = extract_features(file_path)

        pred = model.predict(features)[0]
        pred_label = encoder.inverse_transform([pred])[0]

        print(f"Actual: {label} | Predicted: {pred_label}")

        if pred_label == label:
            correct += 1

        total += 1

print("\nAccuracy:", correct / total)