# # create IAM role for ec2 instance
# # terraform aws create IAM role
# resource "aws_iam_role" "ec2_role" {
#     name = "ec2-role"
#     assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "sts:AssumeRole",
#             "Principal": {
#                 "Service": ["ec2.amazonaws.com"]
#             },
#             "Effect": "Allow",
#         }
#     ]
# }
# EOF

#     tags = {
#         Name = "ec2-role"
#     }
# }

# # create IAM policy for ec2 instance
# # terraform aws create IAM policy
# res