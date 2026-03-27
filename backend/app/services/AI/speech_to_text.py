import whisper

model = whisper.load_model("base")

def convert_audio_to_text(audio_file):
    result = model.transcribe(audio_file)
    return result["text"]