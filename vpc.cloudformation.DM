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

  ###############################################
  #TODO Add EIP for NAT Service
  #TODO Add NAT Service
  #TODO Update Private Route Table to use NAT
  ###############################################

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








 

