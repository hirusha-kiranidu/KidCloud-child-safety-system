import tensorflow as tf
import tensorflow_hub as hub
import numpy as np
import pandas as pd
import librosa

print("Loading YAMNet model...")

# Load YAMNet model
yamnet_model = hub.load("https://tfhub.dev/google/yamnet/1")

# Load class names
class_map_path = yamnet_model.class_map_path().numpy().decode("utf-8")
class_names = list(pd.read_csv(class_map_path)["display_name"])


def detect_yamnet_sound(file_path):

    # Load audio (16kHz required)
    audio, sr = librosa.load(file_path, sr=16000)

    # Normalize audio
    if np.max(np.abs(audio)) > 0:
        audio = audio / np.max(np.abs(audio))

    audio = audio.astype(np.float32)

    # Run YAMNet
    scores, embeddings, spectrogram = yamnet_model(audio)
    scores = scores.numpy()

    # Average predictions
    mean_scores = np.mean(scores, axis=0)

    predicted_index = np.argmax(mean_scores)
    confidence = mean_scores[predicted_index]
    sound_name = class_names[predicted_index]

    #  Ignore unwanted background sounds FIRST
    ignore_sounds = [
        "Water", "Pink noise", "White noise",
        "Wind", "Rain", "Silence", "Noise",
        "Static", "Hiss", "Hum"
    ]

    for noise in ignore_sounds:
        if noise.lower() in sound_name.lower():
            #  Do NOT print anything
            return False

    # Print ONLY useful detections
    print("YAMNet detected:", sound_name)
    print("YAMNet confidence:", round(float(confidence), 2))

    # Danger keywords (expanded for better detection)
    danger_keywords = [
        "Scream", "Shout", "Yell",
        "Crying", "Cry", "Baby cry",
        "Gunshot", "Explosion",
        "Siren", "Alarm",
        "Glass", "Breaking"
    ]

    # Detect danger
    for keyword in danger_keywords:
        if keyword.lower() in sound_name.lower() and confidence > 0.4:
            return True

    return False