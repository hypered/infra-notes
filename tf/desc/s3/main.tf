variable "env_prefix" {
  description = "Prefix for resource names"
  type        = string
}

resource "aws_s3_bucket" "amis" {
  bucket = "${var.env_prefix}-import-bucket"
  acl    = "private"
}

resource "aws_iam_role" "vmimport_role" {
  name               = "${var.env_prefix}-vmimport"
  assume_role_policy = file("${path.module}/vmie-trust-policy.json")
}

resource "aws_iam_role_policy" "vmimport_policy" {
  name   = "${var.env_prefix}-vmimport"
  role   = aws_iam_role.vmimport_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "${aws_s3_bucket.amis.arn}",
        "${aws_s3_bucket.amis.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject",
        "s3:GetBucketAcl"
      ],
      "Resource": [
        "${aws_s3_bucket.amis.arn}",
        "${aws_s3_bucket.amis.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:ModifySnapshotAttribute",
        "ec2:CopySnapshot",
        "ec2:RegisterImage",
        "ec2:Describe*"
      ],
      "Resource": "*"
    }
  ]
    }
EOF
}

output "amis_bucket" {
  value = aws_s3_bucket.amis.bucket
}

output "ami_import_role_name" {
  value = aws_iam_role.vmimport_role.name
}
