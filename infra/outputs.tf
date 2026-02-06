# Outputs for the Rooms POC stack

output "sqs_queue_url" {
  description = "URL of the SQS queue for room messages"
  value       = aws_sqs_queue.rooms_queue.url
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue for room messages"
  value       = aws_sqs_queue.rooms_queue.arn
}

output "sqs_dlq_url" {
  description = "URL of the SQS dead letter queue"
  value       = aws_sqs_queue.rooms_dlq.url
}

output "lambda_function_name" {
  description = "Name of the Lambda function processing room messages"
  value       = aws_lambda_function.rooms_processor.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.rooms_processor.arn
}

output "event_bus_name" {
  description = "Name of the EventBridge event bus"
  value       = aws_cloudwatch_event_bus.rooms_event_bus.name
}

output "event_bus_arn" {
  description = "ARN of the EventBridge event bus"
  value       = aws_cloudwatch_event_bus.rooms_event_bus.arn
}

output "eventbridge_pipe_arn" {
  description = "ARN of the EventBridge Pipe connecting SQS to EventBridge"
  value       = aws_pipes_pipe.sqs_to_eventbridge.arn
}

