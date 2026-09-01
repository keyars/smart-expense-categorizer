from pydantic import BaseModel, Field


class ExpenseInput(BaseModel):
    description: str = Field(min_length=2, max_length=300)
    amount: float = Field(ge=0, le=10000000)


class ExpensePrediction(BaseModel):
    category: str
    confidence: float
    top_predictions: list[dict[str, float | str]]
