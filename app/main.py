from fastapi import FastAPI, HTTPException

from app.schemas import ExpenseInput, ExpensePrediction
from model.predict import predict

app = FastAPI(
    title="Smart Expense Categorizer API",
    version="1.0.0",
    description="Classify expense descriptions into practical spending categories using a lightweight NLP model.",
)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/predict", response_model=ExpensePrediction)
def categorize(expense: ExpenseInput) -> ExpensePrediction:
    try:
        result = predict(expense.description)
        return ExpensePrediction(**result)
    except RuntimeError as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=500, detail="Categorization failed") from exc
