AWSTemplateFormatVersion: 2010-09-09

Description: "AWS CloudFormation script to create a basic VPC setup"

# Usage examples:
# aws cloudformation create-stack --stack-name deadmouse --template-body file://vpc.cloudformation.DM --profile concordDcyr
# aws cloudformation update-stack --stack-name deadmouse --template-body file://vpc.cloudformation.DM --profile concordDcyr
# aws cloudformation delete-stack --stack-name deadmouse --profile concordDcyr

Parameters:
  AppName: 
    Type: String
    Default: DEADMOUSE

  DevDBInstance:
    Type: String
    Default: dbinstance

  DevDBDBName:
    Type: String
    Default: devdmdb

  DevDBMasterUser:
    Type: String
    Default: root

  DevDBMasterPassword:
    Type: String
    Default: replaceMe

  DevDBIsMultiZone:
    Type: String
    Default: false
    
# Regional Map
Mappings: 
  RegionMap:
    us-east-1:
      AZa: us-east-1a
      AZb: us-east-1b
    us-west-2:
      AZa: us-west-2a
      AZb: us-west-2b
      
Resources:

  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: "192.168.0.0/16"
      Tags: 
        - Key: Name
          Value: DM_VPC
        - Key: Application
          Value: 
            Ref: AppName


  SubnetSANDBOX:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: 
        Ref: VPC
      CidrBlock: "192.168.1.0/24"
      AvailabilityZone:
        !FindInMap [ RegionMap, !Ref "AWS::Region", AZa ]
      Tags:
        - Key: Name
          Value: SANDBOX
        - Key: Application
          Value: 
            Ref: AppName

  SubnetDEVWS01a:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: 
        Ref: VPC
      CidrBlock: "192.168.11.0/24"
      AvailabilityZone:
        !FindInMap [ RegionMap, !Ref "AWS::Region", AZa ]
      Tags:
        - Key: Name
          Value: DEVWS01a
        - Key: Application
          Value: 
            Ref: AppName
        - Key: ENV
          Value: DEV

  SubnetDEVWS01b:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: 
        Ref: VPC
      CidrBlock: "192.168.12.0/24"
      AvailabilityZone:
        !FindInMap [ RegionMap, !Ref "AWS::Region", AZb ]
      Tags:
        - Key: Name
          Value: DEVWS01b
        - Key: Application
          Value: 
            Ref: AppName
        - Key: ENV
          Value: DEV

  SubnetDEVDB01a:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: 
        Ref: VPC
      CidrBlock: "192.168.15.0/24"
      AvailabilityZone:
        !FindInMap [ RegionMap, !Ref "AWS::Region", AZa ]
      Tags:
        - Key: Name
          Value: DEVDB01a
        - Key: Application
          Value: 
            Ref: AppName
        - Key: ENV
          Value: DEV

  SubnetDEVDB01b:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: 
        Ref: VPC
      CidrBlock: "192.168.16.0/24"
      AvailabilityZone:
        !FindInMap [ RegionMap, !Ref "AWS::Region", AZb ]
      Tags:
        - Key: Name
          Value: DEVDB01b
        - Key: Application
          Value: 
            Ref: AppName
        - Key: ENV
          Value: DEV

  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: DM_IGW
        - Key: Application
          Value: 
            Ref: AppName

  AttachGateway:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties: 
      VpcId:
        Ref: VPC
      InternetGatewayId:
        Ref: InternetGateway

  PrivateRouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: 
        Ref: VPC
      Tags:
        - Key: Name
          Value: DM_PVT_ROUTE
        - Key: Application
          Value: 
            Ref: AppName

  PublicRouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: 
        Ref: VPC
      Tags:
        - Key: Name
          Value: DM_PUB_ROUTE
        - Key: Application
          Value: 
            Ref: AppName

  PublicRoute:
    Type: AWS::EC2::Route
    DependsOn: AttachGateway
    Properties:
      RouteTableId: 
        Ref: PublicRouteTable
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: 
        Ref: InternetGateway

  SubnetSANDBOXRouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: 
        Ref: SubnetSANDBOX
      RouteTableId: 
        Ref: PublicRouteTable

  SubnetDEVWS01aRouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: 
        Ref: SubnetDEVWS01a
      RouteTableId: 
        Ref: PrivateRouteTable

  SubnetDEVWS01bRouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: 
        Ref: SubnetDEVWS01b
      RouteTableId: 
        Ref: PrivateRouteTable

  SubnetDEVDB01aRouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: 
        Ref: SubnetDEVDB01a
      RouteTableId: 
        Ref: PrivateRouteTable

  SubnetDEVDB01bRouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: 
        Ref: SubnetDEVDB01b
      RouteTableId: 
        Ref: PrivateRouteTable

  ###############################################
  # These are the CIDR blocks for Concord's 
  # networks
  #
  # 66.242.84.0/27
  # 66.242.84.32/27
  # 207.173.232.96/27
  # 75.149.150.96/29
  #
  ###############################################

  DEVSSHAdminAccessSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties: 
      GroupName: DEVSSHAdminAccessSecurityGroup
      GroupDescription: "DEV Security Group for SSH Admin access if we set up a Bastion host."
      SecurityGroupIngress:
          - CidrIp: 66.242.84.0/27
            IpProtocol: tcp
            FromPort: 22
            ToPort: 22
          - CidrIp: 66.242.84.32/27
            IpProtocol: tcp
            FromPort: 22
            ToPort: 22
          - CidrIp: 207.173.232.96/27
            IpProtocol: tcp
            FromPort: 22
            ToPort: 22
          - CidrIp: 75.149.150.96/29
            IpProtocol: tcp
            FromPort: 22
            ToPort: 22
      Tags:
        - Key: Name
          Value: DEV_SSH_ADMIN
        - Key: Application
          Value: 
            Ref: AppName
        - Key: ENV
          Value: DEV
      VpcId:
        Ref: VPC


  RDSDEVClientTrustSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties: 
      GroupName: DEVRDSClientTrustSecurityGroup
      GroupDescription: "DEV Security Group for clients connecting to RDS."
      Tags:
        - Key: Name
          Value: DEVRDSClientTrustSecurityGroup
        - Key: Application
          Value: 
            Ref: AppName
        - Key: ENV
          Value: DEV
      VpcId:
        Ref: VPC
     

  RDSDMDEVDBSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties: 
      GroupName: DEVDMDBSecurityGroup
      GroupDescription: "DEV Security Group for DM data."
      SecurityGroupIngress:
        - SourceSecurityGroupId: 
            Ref: RDSDEVClientTrustSecurityGroup
          IpProtocol: tcp
          FromPort: 3306
          ToPort: 3306
      Tags:
        - Key: Name
          Value: DEVDMDBSecurityGroup
        - Key: Application
          Value: 
            Ref: AppName
        - Key: ENV
          Value: DEV
      VpcId:
        Ref: VPC


  RDSDEVDBSubnetGroup:
    Type: "AWS::RDS::DBSubnetGroup"
    Properties: 
      DBSubnetGroupDescription: "DB Subnet Group for DEV DM."
      SubnetIds:
        - Ref: SubnetDEVDB01a
        - Ref: SubnetDEVDB01b 
      Tags:
        - Key: Name
          Value: RDSDEVDBSubnetGroup
        - Key: Application
          Value: 
            Ref: AppName
        - Key: ENV
          Value: DEV



  RDSDEVDB:
    Type: AWS::RDS::DBInstance
    Properties:
      #
      # Resource Definition
      #
      AllocatedStorage: '5'
      DBInstanceClass: db.t2.micro
      BackupRetentionPeriod: 7
      Engine: MySQL
      DBInstanceIdentifier: 
        Ref: DevDBInstance
      DBName: 
        Ref: DevDBDBName
      #
      # Stub Credentials 
      # will work on shifting to IAM user later
      #
      MasterUsername: 
        Ref: DevDBMasterUser
      MasterUserPassword: 
        Ref: DevDBMasterPassword
      #
      # placement
      # 
      PubliclyAccessible: false
      MultiAZ: 
        Ref: DevDBIsMultiZone
      VPCSecurityGroups:
        - Ref: RDSDMDEVDBSecurityGroup
      DBSubnetGroupName: 
        Ref: RDSDEVDBSubnetGroup
      Tags:
        - Key: Name
          Value: RDSDEVDB
        - Key: Application
          Value: 
            Ref: AppName
        - Key: ENV
          Value: DEV

Outputs:
  VPC:
    Description: Main VPC
    Value: !Ref VPC
    Export:
      Name: "VPC"

  SubnetDEVWS01a: 
    Description: Services Tier Subnet AZ A
    Value: !Ref SubnetDEVWS01a
    Export:
      Name: SubnetDEVWS01a

  SubnetDEVWS01b: 
    Description: Services Tier Subnet AZ B
    Value: !Ref SubnetDEVWS01b
    Export:
      Name: SubnetDEVWS01b

  SubnetSANDBOX: 
    Description: Sandbox Subnet
    Value: !Ref SubnetSANDBOX
    Export:
      Name: SubnetSANDBOX

  RDSDEVClientTrustSecurityGroup:
    Description: Client Trust group for DB Access
    Value: !Ref RDSDEVClientTrustSecurityGroup
    Export:
      Name: RDSDEVClientTrustSecurityGroup

  DEVSSHAdminAccessSecurityGroup:
    Description: SSH access for Administration
    Value: !Ref DEVSSHAdminAccessSecurityGroup
    Export:
      Name: DEVSSHAdminAccessSecurityGroup

