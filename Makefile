cert-manager:
	kubectl apply -f kube/cert-manager/cert-manager.yaml
	kubectl apply -f kube/cert-manager/cluster-issuer.yaml

delete-cert-manager:
	kubectl delete -f kube/cert-manager/cert-manager.yaml
	kubectl delete -f kube/cert-manager/cluster-issuer.yaml

postgres:
	kubectl apply -f kube/postgres/namepsace.yaml
	kubectl apply -f kube/postgres/operator.yaml
	kubectl apply -f kube/postgres/dashboard.yaml

delete-postgres:
	kubectl delete -f kube/postgres/namepsace.yaml
	kubectl delete -f kube/postgres/operator.yaml
	kubectl delete -f kube/postgres/dashboard.yaml

redis:
	kubectl apply -f kube/redis/namespace.yaml
	kubectl apply -f kube/redis/operator.yaml

delete-redis:
	kubectl delete -f kube/redis/namespace.yaml
	kubectl delete -f kube/redis/operator.yaml

dashboard:
	heml repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
	helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard -n kubernetes-dashboard --create-namespace --values kube/dashboard/values.yaml
	kubectl apply -f kube/dashboard/ingress.yaml
	kubectl apply -f kube/dashboard/user.yaml

delete-dashboard:
	helm uninstall kubernetes-dashboard -n kubernetes-dashboard
	kubectl delete -f kube/dashboard/ingress.yaml
	kubectl delete -f kube/dashboard/user.yaml

authentik:
	kubectl apply -f kube/authentik/namespace.yaml
	kubectl create secret generic authentik-secrets \
	  --from-literal=secret-key=$(openssl rand -hex 32) \
	  --from-literal=redis-password=$(openssl rand -hex 32) \
	  --namespace authentik
	kubectl apply -f kube/authentik/authentik-postgres.yaml
	kubectl apply -f kube/authentik/authentik-redis.yaml
	kubectl apply -f kube/authentik/authentik.yaml

delete-authentik:
	kubectl delete -f kube/authentik/namespace.yaml
	kubectl delete -f kube/authentik/authentik-postgres.yaml
	kubectl delete -f kube/authentik/authentik-redis.yaml
	kubectl delete -f kube/authentik/authentik.yaml

deploy:
	make cert-manager
	make postgres
	make redis
	make dashboard
	make authentik

delete:
	make delete-authentik
	make delete-dashboard
	make delete-redis
	make delete-postgres
	make delete-cert-manager