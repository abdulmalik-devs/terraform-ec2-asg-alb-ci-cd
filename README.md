# Provisioning of Two EC2 Instances, AWS Load balancer and ASG using Terraform and Performing CI/CD with GitHub Action.

TThis project uses Terraform to provision an AWS Load Balancer and ASG, with Two EC2 Instances and perform CI/CD with GitHub Actions to automate the deployment of the infrastructure.

N.B: The infrastructure can be deployed to multiple environments (e.g. dev, stage, prod) by using different Terraform workspaces.

## Outputs and GHA Process

![dev_branch-init-and-plan](https://user-images.githubusercontent.com/62616273/233767199-d3f23348-8076-45bf-9729-199a21358f60.png)

![main-init-and-apply](https://user-images.githubusercontent.com/62616273/233767266-f2ce83ac-6423-4d0f-a17b-6c47c09fcea4.png)

![ops-branch-init-and-destroy](https://user-images.githubusercontent.com/62616273/233767317-860f15c7-61e3-4a70-bd29-a3a91437866a.png)

-------------------------------------------------------------------------------------------------------------------------------------------
![nginx-output](https://user-images.githubusercontent.com/62616273/233767341-d5828dff-9b43-4a1c-ba53-b93ce63ed118.png)

![apache-output](https://user-images.githubusercontent.com/62616273/233767375-cad80562-1a5d-4a1c-94ae-4c7274adc0be.png)


## Pre-requisites

- An AWS account.
- Terraform CLI installed.
- AWS CLI installed and configured with access,secret keys and Git Token.

## Usage

1. Clone this repository:

git clone https://github.com/abdulmalik-devs/terraform-ec2-asg-alb-ci-cd.git

2. Check the code and change the neccessary configuration to suite your deployement

3. Initialize the Terraform project:

>terraform init

4. Preview and verify the changes before you apply :

>terraform plan

5. Apply the changes to create the resources:

>terraform apply

6. When you're finished with the resources, destroy them:

>terraform destroy

## Variables

Createt The following variables in your `Github Secrets` file:

| Variable   | Description                                      | Type   |
| ---------- | ------------------------------------------------ | ------ |
| access_key | AWS access key                                   | string |
| secret_key | AWS secret key                                   | string |
| git_token  | Git Token to gain access and permissions         | token  |

## GitHub Actions

This project uses GitHub Actions to perform CI/Cd and automate the deployment of the infrastructure. There are four jobs defined in the `.github/workflows/deploy.yml` file:

1. **lint:** This job format the Terraform code to standard.

2. **terraform-plan-dev-branch:** This job runs `terraform init` and `terraform plan` when a push is made to the `dev-branch` branch. This job will only plan changes, it will not apply them.

3. **terraform-apply-main:** This job runs `terraform apply` when a pull request is closed and merged to the `main` branch. This job will apply the changes.

4. **terraform-destroy-ops-branch:** This job runs `terraform destroy` when a pull request is closed and merged to the `ops-branch` branch. This job will destroy the infrastructure.

## Conclusion

This project demonstrates how to use Terraform to provision an AWS Load Balancer, ASG and Two EC2 Instances, and how use CI/CD Tool like Github Action to automate the deployment of the infrastructure. Feel free to customize the code and workflows to fit your needs.

If you have any further clarification, kindly reach out to me with the below information.

## Author

Abdulmalik Ololade Akindayo

linkedIn: [Abdulmalik Ololade\_](https://www.linkedin.com/in/abdulmalik-ololade/)

Blog: ...In progress...
