# output "front_lb_dns" {
#   value = aws_lb.front_app_lb.dns_name
# }
# output "back_lb_dns" {
#   value = aws_lb.back_app_lb.dns_name
#   sensitive = true
# }

output "db_host" {
  value = aws_db_instance.db_instance1.endpoint
}