resource "aws_iam_role" "bastion" {
  name = "${local.common_name}"

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
    local.common_tags,
    {
        Name = "${local.common_name}-bastion"
    }
  )
}
#IAM POLICY, same is bastion
resource "aws_iam_role_policy_attachment" "bastion" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" #fecth this from aws --> plocies--> admintrator copy arn
}
#IAM PROFILE
resource "aws_iam_instance_profile" "bastion" {
  name = "${local.common_name}-bastion"
  role = aws_iam_role.bastion.name
}

###THIS WILL CREATE A ROLE, GOR EC@ RESOURCE ADD THIS ROLE IN EC2