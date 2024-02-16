**Disclaimer: These instructions alone are not appropriate for true production. I am not a security expert and have not ensured security in every step of this process.**
## Infrastructure Overview
1. A single VPC
2. Three public app subnets - one for development, two for production
3. Four private data subnets - two in one AZ, two in another (for RDS instances)
4. Three EC2 instances - one dev, two production (for blue-green deployment)
5. Two RDS instances - one for production, one for development, each with access to both AZs
6. Routing with Route 53
7. Application Load Balancer with weighted target groups set up for blue-green deployment

## Initial Setup Steps & Tips
1. Install [Terraform](https://developer.hashicorp.com/terraform/install)
	1. [for raspberry pi](https://snapcraft.io/install/terraform/raspbian)
2. Install [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#cliv2-linux-install)
3. Configure cli for terraform with `aws configure --profile terraform-user`
	1. Will need to setup new access key in AWS first
4. Create an S3 bucket to store Terraform State
	1. be sure to enable versioning
5. The [docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) are very helpful for trouble shooting
6. Don't be afraid to use ChatGPT for initial resource setup the adjust based on needs using the AWS Console and Terraform Docs

## VPC & Subnet Setup
1. Follow [this guide](https://aws.plainenglish.io/project-1-host-a-dynamic-ecommerce-website-on-aws-with-terraform-ea93ef2ba15f) or ChatGPT
2. Adjust subnets based on project needs
3. Note that you will need at least two subnets in different AZs for each RDS instance
[main.tf example](https://github.com/b-mitch/terraform_sample/blob/main/main.tf)
[vpc.tf example](https://github.com/b-mitch/terraform_sample/blob/main/main.tf)

variable.tf example (excerpt):
```
# vpc variables
variable "vpc_cidr" {
    default     = "10.0.0.0/16"
    description = "vpc cidr block"
    type        = string 
}

variable "public_subnet_cidr" {
    default     = "10.0.0.0/24"
    description = "public subnet cidr block"
    type        = string 
}
```

## Security Groups Setup
1. Continuing the guide above
2. Be sure to first understand where you need security groups and what their rules should be
3. For example, I did not set up an ALB, so I won't need that security group
4. Be sure to use your **public** IP for the ssh_location variable
	1. I ran `curl ifconfig.me` in terminal to get this
	2. And be sure to append '/32' to make it  cidr block
5. If your webserver is on a public subnet, your http/https rules in the webserver security group will look like mine below
6. I ended up adding ssh ingress to each security group instead of passing this on to an ssh security group since ssh connection would timeout with that setup
7. You'll also want to make sure there are security rules that allow your EC2 instances to connect to your RDS instances. If you try to set this up all within the security groups, you will get a circular reference error. Instead, you'll have to set up in only one or the other. Then, you can add a rule or rules after the security groups. 
[security-group.tf example](https://github.com/b-mitch/terraform_sample/blob/main/security-group.tf)

## EC2 Setup
1. I used [this blog](https://klotzandrew.com/blog/deploy-an-ec2-to-run-docker-with-terraform) to get the right basic structure. 
2. Remember to set everything to the free tier options
3. Added each instance to our subnets created earlier with the attribute 'subnet_id'
4. Create an ssh key pair locally if you don't already have one you'd like to use
5. Create a key pair resource and plug in the public key we just created
	1. Remember to still use variable.tf for this
	2. This is how you will ssh into your instance
6. Be sure to include commands to install docker and add it to the ec2-user's groups on creation. This will allow us to later run docker commands without sudo privileges. I did this with an sh file that I assigned to the user_data attribute for each instance
7. Check the connect - ssh section in your instance console for tips on ssh'ing into the instance
[ec2.tf example](https://github.com/b-mitch/woutfh_project/blob/main/infrastructure/ec2.tf)

## RDS Setup
1. I did not follow the guide since it uses a snapshot here. Instead I used [this post](https://alfrcr.dev/setup-postgresql-on-amazon-rds-using-terraform-5cb81e97e04a) as a template but only used the attributes necessary
2. Be sure to use your variable.tf for database credentials 
3. Also there are some special symbols that will mess up your scripting later so either learn what those are and don't use them or just don't use special symbols at all
4. I found the lowest cost settings by going through the console RDS setup and selecting 'free-tier' in the template section to see what those settings might be
[rds.tf example](https://github.com/b-mitch/terraform_sample/blob/main/rds.tf)

## ALB Setup
1. Jump to the alb section from the guide above 
2. I also used the following guide to set up [blue-green deployments](https://developer.hashicorp.com/terraform/tutorials/aws/blue-green-canary-tests-deployments)
3. I only added one listener for http since I don't yet have https configured for my app
	1. target group weights can be updated based on how much traffic you want flowing to your blue vs green instances
4. I also added target group attachments so that my ALB knows where to route traffic to. Not sure why this wasn't included in the tutorial
5. This is commented out in my code because I ended up creating a separate terraform project for the ALB so that I could manage it separately from my other resources, which allows me to more easily adjust the target group weights for blue-green deployments.
[alb.tf example](https://github.com/b-mitch/terraform_sample/blob/main/alb.tf)

## Route 53 Setup
1. This one is totally optional but highly recommended so that your project be visited via a custom domain instead of an IP address. 
2. You will first need to create a hosted zone in AWS console and purchase your domain. This will be what you assign your 'zone_id' attribute to.
3. For basic setup, you will simply include everything in your Terraform code that you see when creating a record in AWS console (or ask ChatGPT). 
4. Be sure to create at least two records: one for the root domain and one that includes the 'www' subdomain
5. If you end up using an ALB to route traffic, you will have to use an alias instead of records and ttl
[route53.tf example](https://github.com/b-mitch/terraform_sample/blob/main/route53.tf)

## Nat Gateway Setup
1. Jump to the Nat Gateway section from guide above
	1. In EIP resource: `vpc = true` depricated for resource eip. Use: `domain = "vpc"`
2. This step is expensive and not necessary for a small scale personal app
	1. I elected to place my production app in a public subnet instead - less security but lower charge
[nat-gateway.tf example](https://github.com/b-mitch/terraform_sample/blob/main/nat-gateway.tf)
