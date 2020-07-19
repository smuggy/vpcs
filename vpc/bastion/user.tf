resource aws_iam_user user {
  name = "bootstrap"
}

resource aws_iam_policy s3_access {
  name   = "bootstrap-s3-policy"
  policy = data.aws_iam_policy_document.s3_access.json
}

resource aws_iam_user_policy_attachment bootstrap {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.s3_access.arn
}

data aws_iam_policy_document s3_access {
  statement {
    effect    = "Allow"
    resources = [
      "arn:aws:s3:::test-marc-bucket",
      "arn:aws:s3:::test-marc-bucket/*"
    ]
    actions   = [
      "s3:Get*",
      "s3:List*"
    ]
  }
}
//
//principals {
//  identifiers = [aws_iam_user.user.arn]
//  type = "AWS"
//}
