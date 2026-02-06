variable "environment" {
  type        = string
  description = "The environment of the project"
}

variable "project_name" {
  type        = string
  description = "The name of the project"
}

variable "region" {
  description = "The AWS region to deploy into"
  type        = string
}

