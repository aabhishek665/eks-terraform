#!/bin/bash

account_id=$1
cluster_name=$2
region=$3
alb_role_name=$4

cat >aws-load-balancer-controller-service-account.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::${account_id}:role/${alb_role_name}
EOF

kubectl apply -f aws-load-balancer-controller-service-account.yaml

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml

date +"%s"
sleep 30
date +"%s"

curl -Lo v2_4_4_full.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.4.4/v2_4_4_full.yaml

sed -i.bak -e '480,488d' ./v2_4_4_full.yaml

sed -i -e 's/your-cluster-name/'"${cluster_name}"'/g' ./v2_4_4_full.yaml

kubectl apply -f v2_4_4_full.yaml

curl -Lo v2_4_4_ingclass.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.4.4/v2_4_4_ingclass.yaml

kubectl apply -f v2_4_4_ingclass.yaml

set -x
# Declare the script variables for the version and platform of the HNS installation
HNC_VERSION=v1.0.0
HNC_PLATFORM=linux_amd64

# Twiddle with the existing namespaces to exclude for HNS operations
kubectl label ns kube-system hnc.x-k8s.io/excluded-namespace=true --overwrite
kubectl label ns kube-public hnc.x-k8s.io/excluded-namespace=true --overwrite
kubectl label ns kube-node-lease hnc.x-k8s.io/excluded-namespace=true --overwrite

#Install the Hierarchical Namespace Controller
kubectl apply  -f https://github.com/kubernetes-sigs/hierarchical-namespaces/releases/download/${HNC_VERSION}/default.yaml

#Put the installation to sleep for 60 seconds so that Kubernetes can adjust itself
date +"%s"
sleep 60
date +"%s"

# Go a directory that is in the system $PATH
cd /usr/local/bin

# Install the HNS kubectl plugin in that directory
sudo curl -L https://github.com/kubernetes-sigs/hierarchical-namespaces/releases/download/${HNC_VERSION}/kubectl-hns_${HNC_PLATFORM} -o ./kubectl-hns

# Give the plugin executable permission
sudo chmod +x ./kubectl-hns
