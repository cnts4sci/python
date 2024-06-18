group "default" {
    targets = ["python"]
}

variable "ORGANIZATION" {
    default = "cnts4sci"
}

variable "BULID_BASE_IMAGE" {
}

variable "RUNTIME_BASE_IMAGE" {
}

variable "PYTHON_VERSION" {
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
        build-base-image = "docker-image://${BUILD_BASE_IMAGE}"
        runtime-base-image = "docker-image://${RUNTIME_BASE_IMAGE}"
    }
    args = {
      "PYTHON_VERSION" = "${PYTHON_VERSION}"
    }
}

