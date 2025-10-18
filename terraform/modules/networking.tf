#VPC
resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "cloud-project-vpc"
  }
}

#Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main-vpc.id
  #how many time the resource get created (a loop)
  count = length(var.vpc_availability_zones)
  #cidrsubnet is a built in terraform function that creates
  /*
    iteration 1 :
    cidrsubnet(10.0.0.0/16,8,0+1) ==> 10.10.1.0/24
    iteration 2 :
    cidrsubnet(10.0.0.0/16,8,1+1) ==> 10.10.2.0/24

    /24 = /16 + 8
  */
  cidr_block        = cidrsubnet(aws_vpc.main-vpc.cidr_block, 8, count.index + 1)
  availability_zone = var.vpc_availability_zones[count.index]
  tags = {
    Name = "Cloud project Public subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main-vpc.id
  count             = length(var.vpc_availability_zones)
  cidr_block        = cidrsubnet(aws_vpc.main-vpc.cidr_block, 8, count.index + 3)
  availability_zone = var.vpc_availability_zones[count.index]
  tags = {
    Name = "Cloud project Private subnet ${count.index + 1}"
  }
}

#internet GW
resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.main-vpc.id
}

resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
  tags = {
    Name = "Public subnet route table"
  }
}

resource "aws_route_table_association" "public-subnet-route-table-association" {
  route_table_id = aws_route_table.public_subnet_route_table.id
  count          = length(var.vpc_availability_zones)
  subnet_id      = aws_subnet.public_subnet[count.index].id
}
# Elastic IP
/*Its mandatory for nat GW to work*/
resource "aws_eip" "eip" {
  depends_on = [aws_internet_gateway.internet_gw]
}

#Nat GW
resource "aws_nat_gateway" "nat_gw" {
  subnet_id     = aws_subnet.public_subnet[0].id
  depends_on    = [aws_internet_gateway.internet_gw]
  allocation_id = aws_eip.eip.id
}

resource "aws_route_table" "private_subnet_route_table" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "Private subnet route table"
  }
}

resource "aws_route_table_association" "private-subnet-route-table-association" {
  route_table_id = aws_route_table.private_subnet_route_table.id
  count          = length(var.vpc_availability_zones)
  subnet_id      = aws_subnet.private_subnet[count.index].id
}
