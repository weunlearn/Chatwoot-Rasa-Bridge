# The name of your project. A project typically maps 1:1 to a VCS repository.
# This name must be unique for your Waypoint server. If you're running in
# local mode, this must be unique to your machine.
project = "wulu"

# Labels can be specified for organizational purposes.
labels = {
    "role" = "bridge"
    "infrastructure" = "serverless"
}
variable "image_tag" {
    type    = string
    default = "develop"
}
variable "branch" {
    type    = string
    default = "main"
    env     = ["CI_COMMIT_BRANCH"]
}
# An application to deploy.
app "bridge-rasa" {
    # Build specifies how an application should be deployed. In this case,
    # we'll build using a Dockerfile and keeping it in a local registry.
    build {
        use "pack" {}

        # Uncomment below to use a remote docker registry to push your built images.
        #
        registry {
            use "aws-ecr" {
                region     = "ap-south-1"
                repository = "bridge-rasa"
                tag = var.branch == "main" ? "stable" : gitrefpretty()
            }
        }

    }

    # Deploy to Docker
    deploy {
        use "aws-lambda" {
            region = "ap-south-1"
        }
    }

    release {
        use "aws-alb" {
            name = "rasa-bridge"
        }
    }
}
