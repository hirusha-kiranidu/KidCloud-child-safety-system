import sounddevice as sd
from scipy.io.wavfile import write
import librosa
import numpy as np
import pickle

from speech_to_text import convert_audio_to_text
from danger_detection import detect_danger
from advanced_ai.yamnet_detector import detect_yamnet_sound

# Load trained sound model
model = pickle.load(open("models/sound_model.pkl", "rb"))
encoder = pickle.load(open("models/label_encoder.pkl", "rb"))

sample_rate = 16000
duration = 5


def extract_features(file_path):
    audio, sample_rate = librosa.load(file_path, res_type='kaiser_fast')

    mfcc = librosa.feature.mfcc(y=audio, sr=sample_rate, n_mfcc=60)

    mfcc_scaled = np.hstack([
        np.mean(mfcc, axis=1),
        np.std(mfcc, axis=1)
    ])

    return mfcc_scaled.reshape(1, -1)


while True:

    print("\nListening for", duration, "seconds...")

    audio = sd.rec(int(duration * sample_rate),
                   samplerate=sample_rate,
                   channels=1,
                   dtype='float32')

    sd.wait()

    file_path = "live_audio.wav"
    write(file_path, sample_rate, audio)

    print("Audio recorded")

    # -------- Custom Sound Model --------
    features = extract_features(file_path)

    # Get prediction + confidence
    probs = model.predict_proba(features)
    confidence = np.max(probs)

    prediction = model.predict(features)[0]
    sound_prediction = encoder.inverse_transform([prediction])[0]

    print("Custom model detected:", sound_prediction)
    print("Confidence:", round(float(confidence), 2))

    # Ignore weak predictions
    if confidence < 0.5:
        print("⚠ Uncertain prediction - ignoring")
        print("------------------------")
        continue

    # -------- YAMNet Detection --------
    yamnet_danger = detect_yamnet_sound(file_path)

    # -------- Speech Detection --------
    text = convert_audio_to_text(file_path)

    print("Detected speech:", text)

    # -------- Danger Detection --------
    danger_sounds = ["gun_shot", "siren", "screaming", "crying"]

    if detect_danger(text):
        print("⚠ STUDENT MAY BE IN DANGER (Danger Words)")

    elif sound_prediction in danger_sounds and confidence > 0.75:
        print("⚠ DANGER SOUND DETECTED (Custom Model)")

    elif yamnet_danger and confidence > 0.6:
        print("⚠ CONFIRMED DANGER (YAMNet + Confidence)")

    else:
        print("Environment appears safe")

    print("------------------------")