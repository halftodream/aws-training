provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
}

resource "aws_s3_bucket" "my_bucket" {
    bucket = "${var.bucket_name}"
    acl    = "${var.acl_value}"
    # Allow deletion of non-empty bucket
    force_destroy = true
    versioning {
        enabled = true
    }
}

resource "aws_s3_bucket_object" "file_upload" {
    for_each = fileset("files/", "*")
    bucket = aws_s3_bucket.my_bucket.id
    key = each.value
    source = "files/${each.value}"
    etag = filemd5("files/${each.value}")
    # Service account creation is eventually consistent, so add a delay.
    provisioner "local-exec" {
        command = "sleep 10"
    }
}

output "my_bucket_file_version" {
    value = "${aws_s3_bucket_object.file_upload}"
}
