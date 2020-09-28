#Outputs definition

output "alb_dns_name" {
  description = "DNS name of ALB"
  value       = aws_lb.alb_http.dns_name
}
