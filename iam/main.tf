provider "aws" {
  region  = var.region
  profile = var.profile
}

resource "aws_iam_role" "k3s-master-role" {
  name               = "k3s-master-role"
  assume_role_policy = file("data/master_iam_policy.json")
}

resource "aws_iam_instance_profile" "k3s-master-role-profile" {
  name = "k3s-master-role-profile"
  role = aws_iam_role.k3s-master-role.name
}

resource "aws_iam_policy" "master_policy" {
  name        = "master-policy"
  description = "Policy for master"
  policy      = file("data/master_policy.json")
}

resource "aws_iam_role_policy_attachment" "master_attach_policy" {
  role       = aws_iam_role.k3s-master-role.name
  policy_arn = aws_iam_policy.master_policy.arn
}

resource "aws_iam_policy" "ccm_policy" {
  name        = "ccm-policy"
  description = "Policy for ccm"
  policy      = file("data/ccm_master_policy.json")
}

resource "aws_iam_role_policy_attachment" "ccm_attach_policy" {
  role       = aws_iam_role.k3s-master-role.name
  policy_arn = aws_iam_policy.ccm_policy.arn
}
