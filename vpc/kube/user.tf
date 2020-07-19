resource aws_iam_user kubernetes_user {
  name = "kubesa"
}

resource aws_iam_user_policy kubesa_s3 {
  name   = "s3-access"
  user   = aws_iam_user.kubernetes_user.name
  policy = data.aws_iam_policy_document.s3_policy.json
}

data aws_iam_policy_document s3_policy {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["s3:*"]
  }
}

resource aws_iam_policy instance_policy {
  name   = "kube-volume-policy"
  policy = data.aws_iam_policy_document.key_policy.json
}

data aws_iam_policy_document key_policy {

  statement {
    sid       = "keyPolicy"
    effect    = "Allow"
    resources = ["arn:aws:kms:*:123991868349:key/*"]
    actions = [
      "kms:CreateGrant"
    ]
  }

  statement {
    sid       = "ec2Policy"
    effect    = "Allow"
    resources = ["*"]
    actions   = [
      "ec2:DetachVolume",
      "ec2:AttachVolume",
      "ec2:DeleteSnapshot",
      "ec2:DescribeInstances",
      "ec2:DeleteTags",
      "ec2:DescribeTags",
      "ec2:CreateTags",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSecurityGroups",
      "ec2:CreateVolume",
      "ec2:DeleteVolume",
      "ec2:DescribeVolumes",
      "ec2:CreateSnapshot"
    ]
  }
}

resource aws_iam_user_policy_attachment kube_user {
  user       = aws_iam_user.kubernetes_user.name
  policy_arn = aws_iam_policy.instance_policy.arn
}
