Working draft of a Cloudformation script to build out a VPC and subnets for basic project work. This is a work in progress, and better documentation will follow once the bulk of work is done.

Note: in the below, replace the profile name with a profile you have configured using 'aws configure'.

To run this the first time, use:
aws cloudformation create-stack --stack-name myteststack --template-body file://vpc.cloudformation --profile myDave

To update the stack, use:
aws cloudformation update-stack --stack-name myteststack --template-body file://vpc.cloudformation --profile myDave



