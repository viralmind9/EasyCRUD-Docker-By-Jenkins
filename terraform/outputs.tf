output "rds_endpoint" {
  value = aws_db_instance.mariadb.endpoint
}

output "rds_port" {
  value = aws_db_instance.mariadb.port
}
