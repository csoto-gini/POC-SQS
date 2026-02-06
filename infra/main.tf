# Main configuration file for Rooms POC stack
# This POC demonstrates: Endpoint -> SQS -> EventBridge -> Lambda

locals {
  # Common naming convention
  prefix = "${var.project_name}-${var.environment}"
  
  # Tags for all resources
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Stack       = "rooms-poc"
    ManagedBy   = "terraform"
  }
}

