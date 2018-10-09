# Simple Cloudformation setup
## Environment
![alt text](../Images/cloudformation.png "Drupal high available")

The goal of this lab is to spawn a loadbalancer with 2 webservers and EFS. All coded in Cloudformation

## Technologies

1. EC2 instances
    * [EC2 Documentation](https://docs.aws.amazon.com/ec2/index.html?id=docs_gateway#lang/en_us)
1. Loadbalancer
    * [ELB Documentation](https://docs.aws.amazon.com/elastic-load-balancing/index.html?id=docs_gateway#lang/en_us)
1. CloudFormation
    * [CloudFormation Documentation](https://docs.aws.amazon.com/cloudformation/index.html?id=docs_gateway#lang/en_us)

## Configuration Steps

There's not a lot of configuration needed in this lab, therefor we will explain the `yaml template` in depth. Afterwards there are short steps how and where to deploy the template.

        Resources:

Resources is the only thing we need for this lab. The main goal is to use these resources to create the setup.

### Security Group

        InstanceSecurityGroup:
          Type: 'AWS::EC2::SecurityGroup'
          Properties:
            GroupName: "workshop-security-group-1"
            GroupDescription: Enable SSH access via port 22
            SecurityGroupIngress:
              - IpProtocol: tcp
                FromPort: '22'
                ToPort: '22'
                CidrIp: "94.143.189.241/32"
              - IpProtocol: tcp
                FromPort: '80'
                ToPort: '80'
                CidrIp: 0.0.0.0/0

In the codeblock above we created the security group. We define the resource we need with `Type: 'AWS::EC2::SecurityGroup'`. The important properties we are using here are `GroupName` because we are going to need this name in our `EC2 instance` resource. The `SecurityGroupIngress` is going to define what our rules are of the security group. We will allow `ssh` over port `22` from the example `IP address`, this is the Xplore IP. And because we are creating webservers we are allowing port `80` traffic from everywhere.

### Webservers

        Webserver1:
          Type: 'AWS::EC2::Instance'
          Properties:
            SecurityGroupIds: [!Ref 'InstanceSecurityGroup']
            InstanceType: t2.micro
            KeyName: workshop-key-eu
            ImageId: "ami-00035f41c82244dab"
            AvailabilityZone: "eu-west-1a"
            Tags:
              - Key: Name
                Value: "Webserver1"
            UserData:
              Fn::Base64: !Sub |
                 #!/bin/bash -xe
                 apt update -y
                 apt install apache2 -y
                 systemctl stop apache2
                 rm -rf /var/www/html/index.html
                 echo "<h1>Webserver1</h1>" > /var/www/html/index.html
                 systemctl start apache2
                 systemctl enable apache2

The following two codeblocks you see are those of the webservers. Because these are alike we will explain only one. We define the resource with `Type: 'AWS::EC2::Instance'`.All the properties in this codeblock are pretty much important. We start with `SecurityGroupIds: [!Ref 'InstanceSecurityGroup']` this means that we are using the `Security Group` we made initially. With `InstanceType: t2.micro` we say that we want to use a `t2.micro` machine. `KeyName: workshop-key-usa` is used to specify which `keypair` we want to use to access the instance over SSH.

`ImageId` is the ami we will use, in this example it's the Ubuntu 16.04 image on the `us-east-1` region. This takes us to the `AvailabilityZone:` option where we specify the availabilityzone we are using `us-east-1a` is one in North Virginia, the region we are currently in.

The tag is just used to give the machine a name. According to the function of the machine we will give it the name `Webserver1`, this will be `Webserver2` on the second instance. As seen in the `yaml template`. At last we will provide some userdata that will take care of the `apache` installation.

### Loadbalancer

        ElasticLoadBalancer:
          Type: AWS::ElasticLoadBalancing::LoadBalancer
          Properties:
            AvailabilityZones:
              Fn::GetAZs: ''
            Instances:
            - Ref: Webserver1
            - Ref: Webserver2
            Listeners:
            - LoadBalancerPort: '80'
              InstancePort: '80'
              Protocol: HTTP
            HealthCheck:
              Target: HTTP:80/
              HealthyThreshold: '3'
              UnhealthyThreshold: '5'
              Interval: '30'
              Timeout: '5'
            ConnectionDrainingPolicy:
              Enabled: 'true'
              Timeout: '60'

When our webservers are deployed and we have a security group, the only thing we still need is a Loadbalancer. The codeblock above will provide a Loadbalancer in this setup. You can confirm that we're using the Loadbalancer resource by the following code `Type: AWS::ElasticLoadBalancing::LoadBalancer`. The Loadbalancer will check automatically which `AvailabilityZones` the region has.

        AvailabilityZones:
          Fn::GetAZs: ''

The instances that the Loadbalancer is going to serve are both the webservers we made. This is something that is defined with the following codeblock.

        Instances:
        - Ref: Webserver1
        - Ref: Webserver2

In the end the only thing we need to do is create the listeners and healthchecks, this will speak for itself with the following code.

        Listeners:
        - LoadBalancerPort: '80'
          InstancePort: '80'
          Protocol: HTTP
        HealthCheck:
          Target: HTTP:80/
          HealthyThreshold: '3'
          UnhealthyThreshold: '5'
          Interval: '30'
          Timeout: '5'
        ConnectionDrainingPolicy:
          Enabled: 'true'
          Timeout: '60'

## Recap

In this lab we used `Cloudformation` to deploy a basic setup that consists of 2 webservers and a Loadbalancer. We used `infrastructure-as-code` to easily deploy environments.




OUTPUT
