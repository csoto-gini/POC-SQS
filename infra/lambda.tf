# Lambda function to process room messages

# Create ZIP file from Lambda code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.js"
  output_path = "${path.module}/lambda/function.zip"
}

# Lambda Function
resource "aws_lambda_function" "rooms_processor" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${local.prefix}-rooms-processor"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "nodejs20.x"
  timeout          = 30
  memory_size      = 128

  environment {
    variables = {
      ENVIRONMENT  = var.environment
      PROJECT_NAME = var.project_name
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.prefix}-rooms-processor"
  })
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.rooms_processor.function_name}"
  retention_in_days = 7

  tags = merge(local.common_tags, {
    Name = "${local.prefix}-rooms-processor-logs"
  })
}

