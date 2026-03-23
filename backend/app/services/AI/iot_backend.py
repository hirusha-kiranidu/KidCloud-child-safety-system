from flask import Flask, request, jsonify
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

# ==============================
# MAIN API
# ==============================

@app.route('/audio', methods=['POST'])
def receive_audio():
    raw_data = request.data

    # Convert PCM → WAV
    audio_np = np.frombuffer(raw_data, dtype=np.int16)

    with wave.open(FILENAME, 'wb') as wf:
        wf.setnchannels(CHANNELS)
        wf.setsampwidth(SAMPLE_WIDTH)
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(audio_np.tobytes())

    print(f"\n--- New Audio Received ({FILENAME}) ---")

    response_data = {
        "status": "Safe",
        "alerts": []
    }

    try:
        # ==============================
        # LAYER 1: CUSTOM MODEL
        # ==============================
        if sound_model is not None and encoder is not None:
            features = extract_features(FILENAME)

            probs = sound_model.predict_proba(features)
            confidence = np.max(probs)

            prediction = sound_model.predict(features)[0]
            sound_prediction = encoder.inverse_transform([prediction])[0]

            print("Custom model:", sound_prediction)
            print("Confidence:", round(float(confidence), 2))

            # Ignore weak predictions
            if confidence >= 0.5:
                if sound_prediction in ["gun_shot", "siren", "screaming", "crying"]:
                    msg = f"Custom Model: {sound_prediction}"
                    response_data["alerts"].append(msg)
            else:
                print("Low confidence → ignored")

        # ==============================
        #  LAYER 2: YAMNET
        # ==============================
        yamnet_danger = detect_yamnet_sound(FILENAME)

        if yamnet_danger:
            msg = "YAMNet: Dangerous sound detected"
            response_data["alerts"].append(msg)

        # ==============================
        #  LAYER 3: SPEECH ANALYSIS
        # ==============================
        text = convert_audio_to_text(FILENAME)
        print("Speech:", text)

        if text and detect_danger(text):
            msg = f"Speech: Danger words detected ({text})"
            response_data["alerts"].append(msg)

        # ==============================
        #  FINAL DECISION
        # ==============================
        if len(response_data["alerts"]) > 0:
            print("⚠ DANGER DETECTED")
            for alert in response_data["alerts"]:
                print(" -", alert)

            response_data["status"] = "Danger"
        else:
            print("Environment is safe")

    except Exception as e:
        print(" ERROR:", e)
        return jsonify({"error": str(e)}), 500

    return jsonify(response_data)


# ==============================
#  RUN SERVER
# ==============================

if __name__ == '__main__':
    print("Starting IoT Backend Server (Port 5000)...")
    app.run(host='0.0.0.0', port=5000)
