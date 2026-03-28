import os
import librosa
import soundfile as sf

DATASET_PATH = "dataset"

TARGET_SR = 16000   # standard for ML audio
DURATION = 3        # seconds

print("Preparing dataset...")

for root, dirs, files in os.walk(DATASET_PATH):
    for file in files:
        if file.endswith(".wav") or file.endswith(".mp3"):
            
            file_path = os.path.join(root, file)

            try:
                # Load audio
                audio, sr = librosa.load(file_path, sr=TARGET_SR)

                # Fix length to 3 seconds
                target_length = TARGET_SR * DURATION

                if len(audio) > target_length:
                    audio = audio[:target_length]
                else:
                    audio = librosa.util.fix_length(audio, size=target_length)

                # Convert to mono (safety)
                if len(audio.shape) > 1:
                    audio = librosa.to_mono(audio)

                # Save as WAV (overwrite)
                new_file_path = file_path.replace(".mp3", ".wav")
                sf.write(new_file_path, audio, TARGET_SR)

                # Remove old MP3 file
                if file.endswith(".mp3"):
                    os.remove(file_path)

            except Exception as e:
                print(" Error processing:", file_path)

print("Dataset preparation completed!")