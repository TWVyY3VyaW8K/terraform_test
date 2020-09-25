#Outputs definition

output "load_balancer_dns" {
  description = "The DNS name of the load balancer"
  value       = module.elb_http.this_elb_dns_name
}