import pickle
import librosa
import numpy as np

# Load trained model
model = pickle.load(open("models/sound_model.pkl", "rb"))

def extract_features(file_path):
    audio, sample_rate = librosa.load(file_path, res_type='kaiser_fast')
    mfcc = librosa.feature.mfcc(y=audio, sr=sample_rate, n_mfcc=40)
    mfcc_scaled = np.mean(mfcc.T, axis=0)
    return mfcc_scaled.reshape(1, -1)

file = "audio_samples/test_audio.wav"

features = extract_features(file)

prediction = model.predict(features)

print("Predicted Sound Class:", prediction[0])