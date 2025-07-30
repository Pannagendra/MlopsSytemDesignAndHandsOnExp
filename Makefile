train:
	python training/train.py

log:
	python training/log_to_mlflow.py

serve:
	cd serving/app && python main.py

docker-train:
	docker build -t pannagendra/mlops-train -f docker/Dockerfile.train .

docker-api:
	docker build -t pannagendra/mlops-model -f docker/Dockerfile.api .

deploy-kserve:
	kubectl apply -f kserve/deploy.yaml
