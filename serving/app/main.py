from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
from app.model_loader import load_model

app = FastAPI()
model = load_model()

class Features(BaseModel):
    features: List[float]

@app.get("/")
def health_check():
    return {"status": "ok"}

@app.post("/predict")
def predict(input_data: Features):
    prediction = model.predict([input_data.features])
    return {"prediction": prediction[0]}
