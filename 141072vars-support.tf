variable "targets" {
    type                = map(object({
      target_id           = string
      target_port         = number
      target_group_key    = string
    }))
    description = "The targets variable is used to declare one or more targets to attach to a specified target group. Use the name of the target group which you declared in the target_group_config to associate a target to. Check the main.tf under examples folder for reference."
}

variable "target_group_config" {
  type        = map(object({
    load_balancing_algorithm_type   = string
    target_group_name               = string
    port                            = number
    protocol                        = string
    protocol_version                = string
    target_type                     = string
    vpc_id                          = string
    deregistration_delay            = number
    slow_start                      = optional(number, null)
    stickiness = optional(object({
      cookie_duration = optional(number, null)
      enabled         = optional(bool, false)
      type            = optional(string, "lb_cookie")
      cookie_name     = optional(string, null)
    }), {enabled      = false
          type        = "lb_cookie"
        })
    health_check = object({
      protocol            = string
      path                = string
      port                = string
      timeout             = number
      healthy_threshold   = number
      unhealthy_threshold = number
      interval            = number
      matcher             = string

    })
  }))
  description = "The target_group_config variable is used to declare one or more target groups. This is a object type and each block will have the specified fields above. You can declare a target group by naming it which will then be used to associate listeners and attachments"
}