import os
import pandas as pd
import shutil

# Paths
CSV_PATH = "ESC-50-master/meta/esc50.csv"
AUDIO_PATH = "ESC-50-master/audio"
OUTPUT_PATH = "dataset/normal"

# Create output folder
os.makedirs(OUTPUT_PATH, exist_ok=True)

# Load CSV
df = pd.read_csv(CSV_PATH)

# Allowed classes (ONLY normal sounds)

allowed_classes = [
    "rain",
    "wind",
    "breathing",
    "footsteps",
    "clock_tick",
    "keyboard_typing",
    "chirping_birds",
    "clapping",
    "laughing",
    "brushing_teeth",
    "dog",  
    "quiet environment"
]

# Loop and copy files
for index, row in df.iterrows():
    category = row["category"]
    filename = row["filename"]

    if category in allowed_classes:
        src = os.path.join(AUDIO_PATH, filename)
        dst = os.path.join(OUTPUT_PATH, filename)

        shutil.copy(src, dst)

print("Normal sounds extracted successfully!")