# EventBridge resources for connecting SQS to Lambda

# Custom Event Bus for room messages
resource "aws_cloudwatch_event_bus" "rooms_event_bus" {
  name = "${local.prefix}-rooms-event-bus"

  tags = merge(local.common_tags, {
    Name = "${local.prefix}-rooms-event-bus"
  })
}

# EventBridge Pipe to connect SQS to EventBridge
resource "aws_pipes_pipe" "sqs_to_eventbridge" {
  name     = "${local.prefix}-rooms-pipe"
  role_arn = aws_iam_role.eventbridge_pipe_role.arn

  # Source: SQS Queue
  source = aws_sqs_queue.rooms_queue.arn

  # Target: EventBridge Event Bus
  target = aws_cloudwatch_event_bus.rooms_event_bus.arn

  source_parameters {
    sqs_queue_parameters {
      batch_size = 1
    }
  }

  target_parameters {
    eventbridge_event_bus_parameters {
      detail_type = "RoomMessage"
      source      = "rooms.api"
    }

    input_template = <<-EOT
    {
      "email1": <$.body.email1>,
      "email2": <$.body.email2>,
      "roomId": <$.body.roomId>,
      "timestamp": <$.body.timestamp>,
      "messageId": <$.messageId>
    }
    EOT
  }

  tags = merge(local.common_tags, {
    Name = "${local.prefix}-rooms-pipe"
  })
}

# EventBridge Rule to trigger Lambda
resource "aws_cloudwatch_event_rule" "rooms_rule" {
  name           = "${local.prefix}-rooms-rule"
  event_bus_name = aws_cloudwatch_event_bus.rooms_event_bus.name
  description    = "Route room messages to Lambda"

  event_pattern = jsonencode({
    source      = ["rooms.api"]
    detail-type = ["RoomMessage"]
  })

  tags = merge(local.common_tags, {
    Name = "${local.prefix}-rooms-rule"
  })
}

# EventBridge Target - Lambda Function
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule           = aws_cloudwatch_event_rule.rooms_rule.name
  event_bus_name = aws_cloudwatch_event_bus.rooms_event_bus.name
  arn            = aws_lambda_function.rooms_processor.arn
  target_id      = "RoomsProcessorLambda"
}

# Allow EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rooms_processor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rooms_rule.arn
}

