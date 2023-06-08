resource "aws_launch_template" "template" {
  name                   = "ubuntutemplate"
  image_id               = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  key_name               = "5822_authkey_Rajesh"
  user_data              = filebase64("${path.module}/userdata.sh")
  vpc_security_group_ids = [var.security_groups]
}

resource "aws_autoscaling_group" "webtierASG" {
  name                      = "webtierASG"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  vpc_zone_identifier       = [var.publicsubnet1, var.publicsubnet2]
  target_group_arns         = [var.target_group_arns] 
  launch_template {
    id = aws_launch_template.template.id
  }
}

# scale up policy
resource "aws_autoscaling_policy" "scale_up_webtier" {
  name                   = "Scale-up"
  autoscaling_group_name = aws_autoscaling_group.webtierASG.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1" #increasing instance by 1 
  cooldown               = "60"
  policy_type            = "SimpleScaling"
}

# scale up alarm
# alarm will trigger the ASG policy (scale/down) based on the metric (CPUUtilization), comparison_operator, threshold
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm_webtier" {
  alarm_name          = "asg-scale-up-alarm"
  alarm_description   = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "30" # New instance will be created once CPU utilization is higher than 30 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.webtierASG.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_up_webtier.arn]
}

# scale down policy
resource "aws_autoscaling_policy" "scale_down_webtier" {
  name                   = "asg-scale-down"
  autoscaling_group_name = aws_autoscaling_group.webtierASG.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1" # decreasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# scale down alarm
resource "aws_cloudwatch_metric_alarm" "scale_down_alarm_webtier" {
  alarm_name          = "asg-scale-down-alarm"
  alarm_description   = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "5" # Instance will scale down when CPU utilization is lower than 5 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.webtierASG.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_down_webtier.arn]
}
