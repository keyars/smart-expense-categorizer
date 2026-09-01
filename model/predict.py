from pathlib import Path

import joblib

ROOT = Path(__file__).resolve().parents[1]
MODEL_PATH = ROOT / "artifacts" / "expense_classifier.joblib"


def load_model():
    if not MODEL_PATH.exists():
        raise RuntimeError("Model artifact not found. Run: python -m model.train")
    return joblib.load(MODEL_PATH)


def predict(description: str, top_n: int = 3) -> dict:
    model = load_model()
    probabilities = model.predict_proba([description])[0]
    classes = model.classes_
    ranked = sorted(zip(classes, probabilities), key=lambda item: item[1], reverse=True)[:top_n]
    return {
        "category": ranked[0][0],
        "confidence": round(float(ranked[0][1]), 4),
        "top_predictions": [
            {"category": label, "confidence": round(float(score), 4)}
            for label, score in ranked
        ],
    }
