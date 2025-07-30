import mlflow
import mlflow.sklearn

def log_model(model, accuracy, params=None):
    mlflow.set_tracking_uri("http://mlflow-service.mlops.svc.cluster.local:5000")
    mlflow.set_experiment("iris-rf-experiment")

    with mlflow.start_run():
        mlflow.log_params(params or {})
        mlflow.log_metric("accuracy", accuracy)
        mlflow.sklearn.log_model(model, "model")
        print("Model logged to MLflow")
