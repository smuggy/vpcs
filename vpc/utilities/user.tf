resource aws_iam_user prom_user {
  name = "promsa"
}

data aws_iam_policy ec2_access {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource aws_iam_user_policy promsa {
  name = "ec2-access"
  user = aws_iam_user.prom_user.name

  policy = data.aws_iam_policy.ec2_access.policy
}
