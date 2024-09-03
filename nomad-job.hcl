variable "pool" {
    type     = string
    default  = "linux"
}

variable "node" {
    type    = string
    default = "dev-1"
}



job "sonatype-nexus" {
    datacenters = [ "dc1" ]

    node_pool   = "${var.pool}"

    constraint {
        attribute = "${attr.unique.hostname}"
        value     = "${var.node}"
    }   

    group "nexus" {
        count = 1

        volume "nexus" {
            type      = "host"
            read_only = false
            source    = "nexus"
        }

        network {
            mode = "host"
            port "http" { 
                static = 9001 
                to = 8081 
            }
        }

        task "server" {
            driver = "docker"

            config {
                image = "sonatype/nexus3:3.71.0"

                ports = [ "http", "registry" ]

                labels {
                    group = "infra"
                    app   = "nexus"
                    env   = "prod"
                }
            }

            volume_mount {
                volume      = "nexus"
                destination = "/nexus-data"
                read_only   = false
            }

            env {
                INSTALL4J_ADD_VM_PARAMS = "-Xms2703m -Xmx2703m -XX:MaxDirectMemorySize=2703m -Djava.util.prefs.userRoot=/nexus-data/javaprefs"
            }

            resources {
                cpu    = 2000
                memory = 8000
            }

            service {
                name = "sonatype-nexus"
                port = "http"

                tags = [
                    "linux",
                    "nexus"
                ]

                check {
                    type      = "http"
                    port      = "http"
                    method    = "GET"
                    path      = "/service/rest/v1/status"
                    interval  = "30s"
                    timeout   = "5s"
                }
            }
        }
    }
}