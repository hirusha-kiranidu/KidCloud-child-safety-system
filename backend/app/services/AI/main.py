import os
from speech_to_text import convert_audio_to_text
from danger_detection import detect_danger

# build correct absolute path
audio_file = os.path.abspath("audio_samples/test_audio.wav")

print("Audio path:", audio_file)

text = convert_audio_to_text(audio_file)

print("Detected speech:", text)

if detect_danger(text):
    print("⚠ STUDENT MAY BE IN DANGER")
else:
    print("Student appears safe")
    