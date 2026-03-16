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