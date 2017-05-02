AWSTemplateFormatVersion: 2010-09-09

Description: "AWS CloudFormation script to create a basic VPC setup"

Parameters:

  AZa:
    Type: String
    Default: us-west-2a

  AZb:
    Type: String
    Default: us-west-2b

  AppName: 
    Type: String
    Default: DEADMOUSE

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


  SubnetDEVDB01a:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: 
        Ref: VPC
      CidrBlock: "192.168.15.0/24"
      AvailabilityZone:
        Ref: AZa
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
        Ref: AZb
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
  #TODO  Security Group setups?
  ###############################################

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
      DBInstanceIdentifier: devdminstance
      DBName: devdmdb
      #
      # Stub Credentials 
      # will work on shifting to IAM user later
      #
      MasterUsername: root
      MasterUserPassword: putSecretHere
      #
      # placement
      # 
      PubliclyAccessible: false
      MultiAZ: true
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

    






 

