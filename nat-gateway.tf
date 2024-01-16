# allocate elastic ip. this eip will be used for the nat-gateway in the public subnet
# terraform aws allocate elastic ip
resource "aws_eip" "nat_eip" {
    domain = "vpc"
    
    tags = {
        Name = "nat-eip"
    }
}

# create nat gateway in public subnet
# terraform aws create nat gateway
resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = aws_subnet.public_subnet.id

    tags = {
        Name = "nat-gateway"
    }

    depends_on = [aws_internet_gateway.internet_gateway]
}

# create private route table and add route through nat gateway
# terraform aws create route table
resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway.id
    }

    tags = {
        Name = "private-route-table"
    }
}

# associate private app subnet az1 to "private route table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "private_app_subnet_route_table_association" {
    subnet_id = aws_subnet.private_app_subnet.id
    route_table_id = aws_route_table.private_route_table.id
}

# associate private dev data subnet az1 to "private route table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "private_dev_data_subnet_route_table_association" {
    subnet_id = aws_subnet.private_dev_data_subnet.id
    route_table_id = aws_route_table.private_route_table.id
}

# associate private prod data subnet az1 to "private route table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "private_prod_data_subnet_route_table_association" {
    subnet_id = aws_subnet.private_prod_data_subnet.id
    route_table_id = aws_route_table.private_route_table.id
}