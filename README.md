# BasicVPCSetup
Working draft of a CloudFormation script to build out a VPC and subnets for basic project work. This is a work in progress, and better documentation will follow once the bulk of work is done.

## Usage
Note: in the below, replace the profile name with a profile you have configured using 'aws configure'.

* To run this the first time, use:
    * aws cloudformation create-stack --stack-name myteststack --template-body file://vpc.cloudformation --profile myDave

* To update the stack, use:
    * aws cloudformation update-stack --stack-name myteststack --template-body file://vpc.cloudformation --profile myDave

* To Tear Down the stack and all its resources, use:
    * aws cloudformation delete-stack --stack-name myteststack --profile myDave





