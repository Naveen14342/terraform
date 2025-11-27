variable "giant" {
  description = "Instance region"
}

variable "image" {
  description = "AMI for my instance"
  default     = "ami-04eeb425707fa843c"
}

variable "size" {
  description = "Size of my instance"
  default     = "t2.micro"
}
