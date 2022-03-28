locals {
    bucket = "ssita"
    prefix  = "terraform/geo_terragrunt"

    project = "helical-history-342218"
    region  = "us-central1"
    zone    = "us-central1-a"

    root_dir = get_parent_terragrunt_dir()
}


remote_state {
    
    backend = "gcs"
    
    generate = {
        path      = "backend.tf"
        if_exists = "overwrite_terragrunt"
    }

    config = {
        bucket = local.bucket
        prefix  = local.prefix
    }
}

generate "provider" {

    path = "providers.tf"
    if_exists = "overwrite_terragrunt"

    contents = <<EOF

provider "google" { 
    project = "${local.project}"
    region  = "${local.region}"
    zone    = "${local.zone}"
}

EOF
}