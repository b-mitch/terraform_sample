# vpc variables
variable "vpc_cidr" {
    default     = "10.0.0.0/16"
    description = "vpc cidr block"
    type        = string 
}

variable "public_subnet_cidr" {
    default     = "10.0.0.0/24"
    description = "public subnet cidr block"
    type        = string 
}

variable "private_app_subnet_cidr" {
    default     = "10.0.2.0/24"
    description = "private app subnet cidr block"
    type        = string 
}

variable "private_dev_data_subnet_cidr" {
    default     = "10.0.4.0/24"
    description = "private dev data subnet cidr block"
    type        = string 
}

variable "private_prod_data_subnet_cidr" {
    default     = "10.0.6.0/24"
    description = "private prod data subnet cidr block"
    type        = string 
}