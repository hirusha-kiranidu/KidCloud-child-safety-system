import sounddevice as sd
from scipy.io.wavfile import write
import os
from speech_to_text import convert_audio_to_text
from danger_detection import detect_danger

sample_rate = 16000
duration = 5  # seconds

while True:
    print("\nListening for", duration, "seconds...")

    audio = sd.rec(int(duration * sample_rate),
                   samplerate=sample_rate,
                   channels=1)

    sd.wait()
    
    file_path = "live_audio.wav"
    write(file_path, sample_rate, audio)

    print("Audio captured")

    text = convert_audio_to_text(file_path)

