resource "aws_lb" "alb" {
  name               = "${var.businessunit}-${var.environment}-${var.load_balancer_name}"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids

  subnets                           = var.subnet_ids
  enable_cross_zone_load_balancing  = var.cross_zone_load_balancing
  ip_address_type                   = var.ip_address_type
  idle_timeout                      = var.idle_timeout
  drop_invalid_header_fields        = var.drop_invalid_header_fields
  preserve_host_header              = var.preserve_host_header
  xff_header_processing_mode        = var.xff_header_processing_mode

  enable_deletion_protection = false

  #Attributes Required AWS.ALB.003
  access_logs {
    bucket  = var.logging_s3_bucket
    prefix  = "LB-logs"
    enabled = true
  }

  tags = local.common_tags

}

resource "aws_lb_target_group_attachment" "alb_target_group_attachment" {
  for_each = { for k, v in var.targets : k => v }

  target_group_arn  = aws_lb_target_group.target_group[each.value.target_group_key].arn
  target_id         = each.value.target_id
  port              = each.value.target_port

}

resource "aws_lb_target_group" "target_group" {

  for_each = { for k, v in var.target_group_config : k => v }
  dynamic "health_check" {
    for_each = try([each.value.health_check], [])
    content {
      enabled             = try(health_check.value.enabled, null)
      healthy_threshold   = try(health_check.value.healthy_threshold, null)
      interval            = try(health_check.value.interval, null)
      matcher             = try(health_check.value.matcher, null)
      path                = try(health_check.value.path, null)
      port                = try(health_check.value.port, null)
      protocol            = try(health_check.value.protocol, null)
      timeout             = try(health_check.value.timeout, null)
      unhealthy_threshold = try(health_check.value.unhealthy_threshold, null)
    }
  }

    name                          = try(each.value.target_group_name, null)
    port                          = try(each.value.port, null)
    protocol                      = try(each.value.protocol, null)
    protocol_version              = try(each.value.protocol_version, null)
    target_type                   = try(each.value.target_type, null)
    vpc_id                        = try(each.value.vpc_id, null)
    load_balancing_algorithm_type = try(each.value.load_balancing_algorithm_type, null)
    deregistration_delay          = try(each.value.deregistration_delay, null)
    slow_start                    = try(each.value.slow_start, null)

  dynamic "stickiness" {
    for_each = try([each.value.stickiness], [])

    content {
      cookie_duration = try(stickiness.value.cookie_duration, null)
      cookie_name     = try(stickiness.value.cookie_name, null)
      enabled         = try(stickiness.value.enabled, null)
      type            = try(stickiness.value.type, null)
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}