# Backend configuration is in main.tf for simplicity
# For production, use separate backend.tf with:
terraform {
   backend "s3" { 
        bucket         = "devsecops-tfstate-353925322836"  # ← Your real account ID
        key            = "dev/terraform.tfstate"
        region         = "us-east-1"
        encrypt        = true
        use_lockfile = true
    }  
 }
