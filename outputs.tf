#Outputs definition

output "load_balancer_dns" {
  description = "The DNS name of the load balancer"
  value       = module.alb_http.this_lb_dns_name
}
