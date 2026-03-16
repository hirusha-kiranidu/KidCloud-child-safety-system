import tensorflow as tf
import tensorflow_hub as hub
import numpy as np
import pandas as pd
import librosa

print("Loading YAMNet model...")

# Load model
yamnet_model = hub.load("https://tfhub.dev/google/yamnet/1")

# Load class labels
class_map_path = yamnet_model.class_map_path().numpy().decode("utf-8")
class_names = list(pd.read_csv(class_map_path)["display_name"])

danger_sounds = [
    "Scream",
    "Crying",
    "Gunshot",
    "Explosion",
    "Siren"
]

def detect_yamnet_sound(file_path):

    audio, sr = librosa.load(file_path, sr=16000)

    scores, embeddings, spectrogram = yamnet_model(audio)

    scores = scores.numpy()

    mean_scores = np.mean(scores, axis=0)

    predicted_index = np.argmax(mean_scores)

    confidence = mean_scores[predicted_index]

    sound_name = class_names[predicted_index]

    print("YAMNet detected:", sound_name)
    print("YAMNet confidence:", round(float(confidence), 2))

    if sound_name in danger_sounds and confidence > 0.3:
        return True
    else:
        return False