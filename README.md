<!-- BEGIN_TF_DOCS -->
# AWS CTFd and EKS Terraform module

Terraform module to deploy [CTFd](https://ctfd.io/) into scalable but small AWS infrastructure and provision EKS suitable for challenge deployment.

# Setup

```
terraform init --upgrade
```

# Setup
```
terraform apply [-var '']
```

# k8s setup 

Note this overwrites your ~/.kube/config only do this if that is what you want
```
terraform output -raw kubeconfig > ~/.kube/config

```