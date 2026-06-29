# we are creating s IAM POLICY AND ROLE TO MYSQL AND ATTACH TO MYSQL EC2 INSTANCE
# created policy for role and policy for mysql 
# we are attaching thagt policy to ec2 instanc mysql

# we are taking ec2 instance iam  role from terraform document
resource "aws_iam_role" "test_role" {
  name = "local.common_name-mysql"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    {
    name = "local.common_name-mysql"
    },
    local.common_tags
  )
}

#ROLE create , now we need policy

resource "aws_iam_policy" "mysql" {
  name        = "local.common_name-mysql"
  path        = "/"
  description = "Policy to read MySQL SSM paramter to attach to mysql instance"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "ssm:GetParameter",
            "Resource": "arn:aws:ssm:us-east-1:565139240657:parameter/roboshop/dev/mysql_root_password"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "ssm:DescribeParameters",
            "Resource": "*"
        }
    ]

  })
}


resource "aws_iam_role_policy_attachment" "mysql" {
  role       = aws_iam_role.mysql.name
  policy_arn = aws_iam_policy.mysql.arn
}

resource "aws_iam_instance_profile" "mysql" {
  name = "${local.common_name}-mysql"
  role = aws_iam_role.mysql.name
}