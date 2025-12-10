output "RDS_Endpoint" {
  value = module.db.db_endpoint
}

output "alb_dns_from_module" {
  value = module.alb.lb_dns
}


