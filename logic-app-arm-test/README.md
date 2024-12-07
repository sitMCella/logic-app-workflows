# Logic App Automation

The following project consists of one Azure Logic App configured with 
one API Connector for Azure Resource Manager.

One step of the Logic App workflow makes use of Azure Resource Manager to 
retrieve the list of resources in one Subscription.

## Terraform

Initialize the Terraform project:

```sh
terraform init
```

Verify the Terraform configuration:

```sh
terraform plan
```

Apply the Terraform configuration:

```sh
terraform apply -auto-approve
```
