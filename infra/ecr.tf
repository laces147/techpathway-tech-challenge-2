resource "aws_ecr_repository" "frontend" {
  name                 = "techpathway-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "techpathway-frontend"
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = "techpathway-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "techpathway-backend"
  }
}