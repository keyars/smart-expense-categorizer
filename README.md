# Smart Expense Categorizer

A small AI/ML application that turns everyday transaction descriptions into useful spending categories.

## Product flow

`Expense description → TF-IDF → Logistic Regression → Category + confidence → Flutter UI`

## Examples

- AWS monthly server bill → Software & Cloud
- Uber ride to office → Transportation
- Dinner at restaurant → Food & Dining
- Salary credited → Income

## Stack

Python, Pandas, scikit-learn, TF-IDF, Logistic Regression, FastAPI, Flutter, Docker, GitHub Actions.

## Run the API

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python -m model.train
uvicorn app.main:app --reload
```

Open `http://127.0.0.1:8000/docs` for interactive API documentation.

## Run Flutter

```bash
cd flutter_app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

For a physical device, use the host machine's LAN IP instead of `10.0.2.2`.

## Architecture

```text
Flutter
   │ POST /predict
   ▼
FastAPI
   │
   ▼
TF-IDF + Logistic Regression
   │
   ▼
Category + confidence + Top 3
```

## V1 UX

The Flutter client includes an expense description field, optional amount, one-tap demo examples, loading and error states, category result, confidence meter, top predictions, reset flow, and responsive layout.

## Model note

The included dataset is synthetic and intentionally small. It demonstrates the ML-to-product workflow and is not suitable for real financial automation without representative historical data and proper validation.

## Project status

V1 includes the NLP training pipeline, reusable predictor, FastAPI endpoint, Flutter UI, tests, Docker support, and GitHub Actions CI.