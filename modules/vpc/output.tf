output "security_groups_web" {
    value = aws_security_group.webtiersg.id
}

output "publicsubnet1" {
  value = aws_subnet.dellsubnet1.id
}

output "publicsubnet2" {
  value = aws_subnet.dellsubnet2.id
}

output "vpc_id" {
  value = aws_vpc.dellvpc.id
}

output "security_groups_app" {
 value = aws_security_group.webtiersg.id
}

output "aws_db_subnet_group" {
 value = aws_db_subnet_group.mysql.name
}

output "vpc_security_group_ids" {
  value = aws_security_group.myrdsg.id
}