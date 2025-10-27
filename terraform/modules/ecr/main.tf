resource "aws_ecr_repository" "repo" {
name = var.name
image_tag_mutability = "MUTABLE"
image_scanning_configuration { scan_on_push = true }
}
output "repository_url" { value = aws_ecr_repository.repo.repository_url }
output "repository_name" { value = aws_ecr_repository.repo.name }
