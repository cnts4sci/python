group "default" {
    targets = ["python"]
}

variable "ORGANIZATION" {
    default = "cnts4sci"
}

variable "VERSION" {
}

variable "REGISTRY" {
    default = "ghcr.io"
}

function "tags" {
  params = [image]
  result = [
    "${REGISTRY}/${ORGANIZATION}/${image}",
  ]
}

target "python-meta" {
    tags = tags("python")
}

target "python" {
    inherits = ["python-meta"]
    context = "."
    contexts = {
        build-base-image = "docker-image://ghcr.io/cnts4sci/bm:2024.1001"
        runtime-base-image = "docker-image://ghcr.io/cnts4sci/bm:2024.1001"
    }
    args = {
      "PYTHON_VERSION" = "${VERSION}"
    }
}

