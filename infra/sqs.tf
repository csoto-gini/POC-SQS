# SQS Queue for receiving room messages from the API

resource "aws_sqs_queue" "rooms_queue" {
  name                       = "${local.prefix}-rooms-queue"
  delay_seconds              = 0
  max_message_size           = 262144  # 256 KB
  message_retention_seconds  = 345600  # 4 days
  receive_wait_time_seconds  = 0
  visibility_timeout_seconds = 30

  # Enable dead letter queue for failed messages
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.rooms_dlq.arn
    maxReceiveCount     = 3
  })

  tags = merge(local.common_tags, {
    Name = "${local.prefix}-rooms-queue"
  })
}

# Dead Letter Queue for failed messages
resource "aws_sqs_queue" "rooms_dlq" {
  name                       = "${local.prefix}-rooms-dlq"
  message_retention_seconds  = 1209600  # 14 days

  tags = merge(local.common_tags, {
    Name = "${local.prefix}-rooms-dlq"
  })
}

# Policy to allow EventBridge to read from SQS
resource "aws_sqs_queue_policy" "rooms_queue_policy" {
  queue_url = aws_sqs_queue.rooms_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEventBridgePipeToReadSQS"
        Effect = "Allow"
        Principal = {
          Service = "pipes.amazonaws.com"
        }
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.rooms_queue.arn
      }
    ]
  })
}

