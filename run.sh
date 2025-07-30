#!/bin/bash

echo "Setting up virtual environment..."
python3 -m venv .venv
source .venv/bin/activate

echo "Installing dependencies..."
pip install -r requirements.txt

echo "Training the model..."
make train

echo "Logging to MLflow..."
make log

echo "Starting API server..."
make serve