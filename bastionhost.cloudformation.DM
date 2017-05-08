
# Mapping:
#
# amazon linux us-east-1: ami-c58c1dd3
#
# ImageId
#

Resources:

  BastionHost:
    Type: AWS::EC2::Instance
    Properties: 
      ImageId: ami-c58c1dd3           # REPLACE THIS WITH A MAPPING
      InstanceType: t2.micro 
      KeyName: scratchKey
      Tags:
        - Key: Name
          Value: AUTOBASTION
        - Key: Application
          Value: Deadmouse
        - Key: ENV
          Value: DEV
      NetworkInterfaces: 
        - AssociatePublicIpAddress: "true"
          DeviceIndex: "0"
          GroupSet: 
            - !ImportValue DEVSSHAdminAccessSecurityGroup
            - !ImportValue RDSDEVClientTrustSecurityGroup
          SubnetId: !ImportValue SubnetSANDBOX 
      UserData:
        Fn::Base64: | 
          #!/bin/bash
          yum update -y
          yum install -y mysql
          yum install -y git


