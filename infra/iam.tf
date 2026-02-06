# IAM Roles and Policies for the Rooms POC

# ============================================
# Lambda IAM Role
# ============================================

resource "aws_iam_role" "lambda_role" {
  name = "${local.prefix}-rooms-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.prefix}-rooms-lambda-role"
  })
}

# Lambda basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom policy for Lambda to write logs
resource "aws_iam_role_policy" "lambda_logging" {
  name = "${local.prefix}-lambda-logging"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# ============================================
# EventBridge Pipe IAM Role
# ============================================

resource "aws_iam_role" "eventbridge_pipe_role" {
  name = "${local.prefix}-eventbridge-pipe-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "pipes.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.prefix}-eventbridge-pipe-role"
  })
}

# Policy to allow Pipe to read from SQS
resource "aws_iam_role_policy" "pipe_source_policy" {
  name = "${local.prefix}-pipe-source-policy"
  role = aws_iam_role.eventbridge_pipe_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
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

# Policy to allow Pipe to send to EventBridge
resource "aws_iam_role_policy" "pipe_target_policy" {
  name = "${local.prefix}-pipe-target-policy"
  role = aws_iam_role.eventbridge_pipe_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "events:PutEvents"
        ]
        Resource = aws_cloudwatch_event_bus.rooms_event_bus.arn
      }
    ]
  })
}

