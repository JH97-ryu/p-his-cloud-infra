provider "aws" {
  region = "ap-northeast-2"
}

# 1. 테라폼 상태(도면)를 저장할 S3 버킷
resource "aws_s3_bucket" "terraform_state" {
  # ★ 주의: 버킷 이름은 전 세계에서 유일해야 합니다! '본인이니셜-날짜' 등으로 살짝 수정해 주세요.
  bucket = "p-his-tf-state-unique-12345" 
}

# 1-1. S3 버킷 버저닝 활성화 (안전 복구용)
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 2. 동시 작업 충돌을 막아줄 DynamoDB 자물쇠
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "p-his-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}