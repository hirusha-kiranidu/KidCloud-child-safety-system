rom flask import Flask, request, jsonify
import numpy as np
import wave
import pickle
import librosa

# Import your existing ML pipeline
from speech_to_text import convert_audio_to_text
from danger_detection import detect_danger
from advanced_ai.yamnet_detector import detect_yamnet_sound

app = Flask(__name__)

SAMPLE_RATE = 16000
CHANNELS = 1
SAMPLE_WIDTH = 2  # 16-bit
FILENAME = "iot_live_audio.wav"

# ==============================
#  LOAD MODELS (ONCE)
# ==============================

print("Loading Custom Sound Model...")

try:
    sound_model = pickle.load(open("models/sound_model.pkl", "rb"))
    encoder = pickle.load(open("models/label_encoder.pkl", "rb"))
    print("Custom model loaded successfully!")
except Exception as e:
    print("⚠ Error loading model:", e)
    sound_model = None
    encoder = None


# ==============================
#  FEATURE EXTRACTION
# ==============================

def extract_features(file_path):
    audio, sample_rate = librosa.load(file_path, sr=16000)

    mfcc = librosa.feature.mfcc(y=audio, sr=sample_rate, n_mfcc=40)
    mfcc_scaled = np.mean(mfcc.T, axis=0)

    return mfcc_scaled.reshape(1, -1)