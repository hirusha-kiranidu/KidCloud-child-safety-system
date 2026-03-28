import librosa
import numpy as np

def extract_features(audio_file):

    audio, sample_rate = librosa.load(audio_file)

    mfcc = librosa.feature.mfcc(
        y=audio,
        sr=sample_rate,
        n_mfcc=40
    )

    features = np.mean(mfcc.T, axis=0)

    return features