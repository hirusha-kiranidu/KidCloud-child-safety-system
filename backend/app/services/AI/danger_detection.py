danger_keywords = [
    "help",
    "stop",
    "leave me",
    "danger",
    "don't touch"
]

def detect_danger(text):

    text = text.lower()

    for word in danger_keywords:
        if word in text:
            return True

    return False