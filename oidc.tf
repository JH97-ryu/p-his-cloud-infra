# 1. GitHub OIDC 출입국 관리소 등록
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"] 
}

# 2. GitHub Actions 봇이 사용할 권한(Role) 생성
resource "aws_iam_role" "github_actions" {
  name = "p-his-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
       Condition = {
      StringEquals = {
        "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
      }
      StringLike = {
        "token.actions.githubusercontent.com:sub" = "repo:JH97-ryu/p-his-cloud-infra:*"
      }
    }
      }
    ]
  })
}

# 3. 봇에게 최고 관리자 권한 부여 (인프라 생성용)
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# 4. 완료 후 봇의 신분증 번호(ARN) 출력
output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
} 