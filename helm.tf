provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
#
resource "helm_release" "nginx_ingress" {
  name              = "nginx-ingress"
  chart             = "ingress-nginx"
  repository        = "https://kubernetes.github.io/ingress-nginx"
  namespace         = "ingress-nginx"
  create_namespace  = true

  set {
    name  = "controller.replicaCount"
    value = "1"
  }

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.allowSnippetAnnotations"
    value = "true"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-connection-idle-timeout"
    value = "3600"
  }

#  set {
#    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
#    value = "internal"
#  }
#
#  set {
#    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal"
#    value = "true"
#  }
#
#  set {
#    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
#    value = "true"
#  }
#
#  set {
#    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"
#    value = "tcp"
#  }

}


resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  namespace  = "cert-manager"
  create_namespace = true


  set {
    name  = "installCRDs"
    value = "true"
  }
}


resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"

  # You can specify values.yaml configurations using the set block.
#  set {
#    name  = "someParameter"
#    value = "someValue"
#  }
}

