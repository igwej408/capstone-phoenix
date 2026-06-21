cat > RUNBOOK.md << 'EOF'
# Runbook

## Provision from Zero

### 1. Infrastructure
```bash
cd infra/terraform
terraform init
terraform apply
# Note the output IPs
```

### 2. Update Ansible inventory
Edit `infra/ansible/inventory.ini` with the output IPs.

### 3. Install k3s cluster
```bash
cd infra/ansible
ansible-playbook site.yml
```

### 4. Configure kubectl
```bash
scp -i ~/.ssh/taskappp.pem ubuntu@<control-plane-ip>:/etc/rancher/k3s/k3s.yaml ~/.kube/config
sed -i 's/127.0.0.1/<control-plane-ip>/g' ~/.kube/config
kubectl get nodes
```

### 5. Install platform components
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.5/cert-manager.yaml
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### 6. Install Argo CD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 7. Apply manifests and GitOps
```bash
kubectl apply -f manifests/namespace.yaml
kubectl apply -f manifests/secret.yaml
kubectl apply -f gitops/taskapp-application.yaml
# Argo CD will sync all remaining manifests automatically
```

---

## Scale the App
```bash
# Edit replicas in manifests/backend-deployment.yaml
# Then push to git - Argo CD applies automatically
git add manifests/backend-deployment.yaml
git commit -m "scale: increase backend replicas"
git push origin main
```

---

## Roll Back a Bad Deploy
```bash
# Find the previous good commit
git log --oneline

# Revert to it
git revert HEAD
git push origin main
# Argo CD will automatically roll back
```

---

## Recover from a Dead Worker
```bash
# Check which node is down
kubectl get nodes

# Pods will reschedule automatically
kubectl get pods -n taskapp -o wide

# If node won't recover, terminate it in AWS and provision a new one
# Then re-run ansible to join it to the cluster
```

---

## Recover from a Dead Backend Pod
```bash
# Kubernetes restarts it automatically via liveness probe
# Check status
kubectl get pods -n taskapp
kubectl describe pod <pod-name> -n taskapp
```

---

## Recover from a Bad Migration
```bash
# Delete the failed job
kubectl delete job taskapp-migration -n taskapp

# Fix the migration file, push to git
# Manually re-run if needed
kubectl apply -f manifests/migration-job.yaml
```
EOF