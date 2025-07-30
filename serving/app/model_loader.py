import joblib
from pathlib import Path

_model = None

def load_model():
    global _model
    if _model is None:
        model_path = Path("model.joblib")
        if not model_path.exists():
            raise FileNotFoundError("Model file not found")
        _model = joblib.load(model_path)
    return _model
