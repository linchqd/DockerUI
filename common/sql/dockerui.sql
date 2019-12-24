-- MySQL dump 10.14  Distrib 5.5.64-MariaDB, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: dockerui
-- ------------------------------------------------------
-- Server version	10.4.8-MariaDB-1:10.4.8+maria~bionic

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `document_kinds`
--

DROP TABLE IF EXISTS `document_kinds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_kinds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(16) NOT NULL,
  `ctime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `document_kinds`
--

LOCK TABLES `document_kinds` WRITE;
/*!40000 ALTER TABLE `document_kinds` DISABLE KEYS */;
INSERT INTO `document_kinds` VALUES (1,'数据库','2019-12-23 10:26:33'),(2,'kubernetes','2019-12-23 10:29:07');
/*!40000 ALTER TABLE `document_kinds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents`
--

DROP TABLE IF EXISTS `documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(64) NOT NULL,
  `context` text NOT NULL,
  `tag` varchar(32) NOT NULL,
  `author` varchar(16) NOT NULL,
  `ctime` datetime DEFAULT NULL,
  `kind_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `kind_id` (`kind_id`),
  CONSTRAINT `documents_ibfk_1` FOREIGN KEY (`kind_id`) REFERENCES `document_kinds` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents`
--

LOCK TABLES `documents` WRITE;
/*!40000 ALTER TABLE `documents` DISABLE KEYS */;
INSERT INTO `documents` VALUES (2,'kubernetes etcd.json','# etcd.json\n```yml\n{\n  \"apiVersion\": \"v1\",\n  \"kind\": \"Pod\",\n  \"metadata\": {\n    \"name\":\"kube-etcd\",\n    \"namespace\": \"kube-system\",\n    \"annotations\": {\n      \"scheduler.alpha.kubernetes.io/critical-pod\": \"\",\n      \"seccomp.security.alpha.kubernetes.io/pod\": \"docker/default\"\n     }\n  },\n  \"spec\": {\n    \"hostNetwork\": true,\n    \"containers\":[{\n      \"name\": \"kube-etcd\",\n      \"image\": \"{{etcd_images}}\",\n      \"resources\": {\n        \"requests\": {\n          \"cpu\": \"{{etcd_request_cpu}}\",\n          \"memory\": \"{{etcd_request_memory}}\"\n        },\n        \"limits\": {\n          \"cpu\": \"{{etcd_limit_cpu}}\",\n          \"memory\": \"{{etcd_limit_memory}}\"\n        }\n      },\n      \"livenessProbe\": {\n        \"exec\": {\n          \"command\": [\"/bin/sh\", \"-ec\", \"ETCDCTL_API=3 etcdctl --endpoints=127.0.0.1:2379 get foo\"]\n        },\n        \"failureThreshold\": 8,\n        \"initialDelaySeconds\": 15,\n        \"timeoutSeconds\": 15\n      },\n      \"command\": [\n        \"/bin/sh\",\n        \"-c\",\n        \"if [ -e /usr/local/bin/migrate-if-needed.sh ]; then /usr/local/bin/migrate-if-needed.sh 1>>/var/log/etcd.log 2>&1; fi; exec /usr/local/bin/etcd --data-dir=/var/lib/etcd/data --name=kube-etcd-{{index}} --cert-file=/etc/ssl/etcd.pem --key-file=/etc/ssl/etcd-key.pem --trusted-ca-file=/etc/ssl/ca.pem --peer-cert-file=/etc/ssl/etcd.pem --peer-key-file=/etc/ssl/etcd-key.pem --peer-trusted-ca-file=/etc/ssl/ca.pem --peer-client-cert-auth --client-cert-auth --listen-peer-urls=https://{{ansible_host}}:2380 --initial-advertise-peer-urls=https://{{ansible_host}}:2380 --listen-client-urls=https://{{ansible_host}}:2379,https://127.0.0.1:2379 --advertise-client-urls=https://{{ansible_host}}:2379 --initial-cluster-token=kube-etcd-cluster --initial-cluster={{etcd_cluster}} --initial-cluster-state=new --auto-compaction-mode=periodic --auto-compaction-retention=1 --max-request-bytes=33554432 --quota-backend-bytes=6442450944 --heartbeat-interval=1000 --election-timeout=10000 --snapshot-count=10000 --max-snapshots=5 --max-wals=5 1>>/var/log/etcd.log 2>&1\"\n      ],\n      \"volumeMounts\": [\n        { \n          \"name\": \"etcd-key-pem\",\n          \"mountPath\": \"/etc/ssl/etcd-key.pem\",\n          \"readOnly\": true\n        },\n        { \n          \"name\": \"etcd-pem\",\n          \"mountPath\": \"/etc/ssl/etcd.pem\",\n          \"readOnly\": true\n        },\n        { \n          \"name\": \"ca-pem\",\n          \"mountPath\": \"/etc/ssl/ca.pem\",\n          \"readOnly\": true\n        },\n        { \n          \"name\": \"etcd-log\",\n          \"mountPath\": \"/var/log/etcd.log\",\n          \"readOnly\": false\n        },\n        { \n          \"name\": \"etcd-data\",\n          \"mountPath\": \"/var/lib/etcd/data\",\n          \"readOnly\": false\n        }\n      ]\n    }],\n    \"volumes\":[\n      {\n        \"name\": \"etcd-key-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/etcd-key.pem\"\n        }\n      },\n      { \n        \"name\": \"etcd-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/etcd.pem\"\n        }\n      },\n      {\n        \"name\": \"ca-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/ca.pem\"\n        }\n      },\n      { \n        \"name\": \"etcd-log\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/logs/etcd.log\",\n          \"type\": \"FileOrCreate\"\n        }\n      },\n      { \n        \"name\": \"etcd-data\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/data/etcd\",\n          \"type\": \"DirectoryOrCreate\"\n        }\n      }\n    ]\n  }\n}\n```','k8s,etcd','admin','2019-12-23 11:29:19',2),(3,'kubernetes kube-apiserver.json','# kube-apiserver.json\n```yml\n{\n  \"apiVersion\": \"v1\",\n  \"kind\": \"Pod\",\n  \"metadata\": {\n    \"name\":\"kube-apiserver\",\n    \"namespace\": \"kube-system\",\n    \"annotations\": {\n      \"scheduler.alpha.kubernetes.io/critical-pod\": \"\",\n      \"seccomp.security.alpha.kubernetes.io/pod\": \"docker/default\"\n    },\n    \"labels\": {\n      \"tier\": \"control-plane\",\n      \"component\": \"kube-apiserver\",\n      \"type.pod.kubernetes.io\": \"system\"\n    }\n  },\n  \"spec\":{\n    \"hostNetwork\": true,\n    \"containers\":[\n      {\n        \"name\": \"kube-apiserver\",\n        \"image\": \"{{kube_apiserver_images}}\",\n        \"resources\": {\n          \"requests\": {\n            \"cpu\": \"{{kube_apiserver_request_cpu}}\",\n            \"memory\": \"{{kube_apiserver_request_memory}}\"\n          },\n          \"limits\": {\n            \"cpu\": \"{{kube_apiserver_limit_cpu}}\",\n            \"memory\": \"{{kube_apiserver_limit_memory}}\"\n          }\n        },\n        \"livenessProbe\": {\n          \"httpGet\": {\n            \"scheme\": \"HTTPS\",\n            \"host\": \"127.0.0.1\",\n            \"port\": 6443,\n            \"path\": \"/livez?exclude=etcd&exclude=kms-provider-0&exclude=kms-provider-1\"\n          },\n          \"initialDelaySeconds\": 15,\n          \"timeoutSeconds\": 15\n        },\n        \"command\": [\n           \"/bin/sh\",\n           \"-c\",\n           \"exec /usr/local/bin/kube-apiserver --advertise-address={{ansible_host}} --default-not-ready-toleration-seconds=360 --default-unreachable-toleration-seconds=360 --feature-gates=DynamicAuditing=true --max-mutating-requests-inflight=2000 --max-requests-inflight=4000 --default-watch-cache-size=200 --delete-collection-workers=2 --encryption-provider-config=/etc/kubernetes/encryption-config.yaml --etcd-cafile=/etc/kubernetes/ssl/ca.pem --etcd-certfile=/etc/kubernetes/ssl/kubernetes.pem --etcd-keyfile=/etc/kubernetes/ssl/kubernetes-key.pem --etcd-servers={{etcd_cluster}} --bind-address={{ansible_host}} --secure-port=6443 --tls-cert-file=/etc/kubernetes/ssl/kubernetes.pem --tls-private-key-file=/etc/kubernetes/ssl/kubernetes-key.pem --insecure-port=0 --audit-dynamic-configuration --audit-log-maxage=15 --audit-log-maxbackup=3 --audit-log-maxsize=100 --audit-log-truncate-enabled --audit-log-path=/var/log/kube-apiserver-audit.log --audit-policy-file=/etc/kubernetes/audit-policy.yaml --profiling --anonymous-auth=false --client-ca-file=/etc/kubernetes/ssl/ca.pem --requestheader-allowed-names=\\\"aggregator\\\" --requestheader-client-ca-file=/etc/kubernetes/ssl/ca.pem --requestheader-extra-headers-prefix=\\\"X-Remote-Extra-\\\" --requestheader-group-headers=X-Remote-Group --requestheader-username-headers=X-Remote-User --service-account-key-file=/etc/kubernetes/ssl/ca.pem --authorization-mode=RBAC --runtime-config=api/all=true --enable-admission-plugins=NodeRestriction --allow-privileged=true --apiserver-count=3 --event-ttl=168h --kubelet-certificate-authority=/etc/kubernetes/ssl/ca.pem --kubelet-client-certificate=/etc/kubernetes/ssl/kubernetes.pem --kubelet-client-key=/etc/kubernetes/ssl/kubernetes-key.pem --kubelet-https=true --kubelet-timeout=10s --proxy-client-cert-file=/etc/kubernetes/ssl/proxy-client.pem --proxy-client-key-file=/etc/kubernetes/ssl/proxy-client-key.pem --service-cluster-ip-range={{cluster_service_ip_range}} --service-node-port-range={{cluster_node_port_range}} --logtostderr=true --v=3 1>>/var/log/kube-apiserver.log 2>&1\"\n        ],\n        \"volumeMounts\": [\n          { \n            \"name\": \"encryption-config\",\n            \"mountPath\": \"/etc/kubernetes/encryption-config.yaml\",\n            \"readOnly\": true\n          },\n          { \n            \"name\": \"audit-policy-config\",\n            \"mountPath\": \"/etc/kubernetes/audit-policy.yaml\",\n            \"readOnly\": true\n          },\n          { \n            \"name\": \"apiserver-logfile\",\n            \"mountPath\": \"/var/log/kube-apiserver.log\",\n            \"readOnly\": false\n          },\n          { \n            \"name\": \"audit-logfile\",\n            \"mountPath\": \"/var/log/kube-apiserver-audit.log\",\n            \"readOnly\": false\n          },\n          { \n            \"name\": \"kubernetes-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/kubernetes.pem\",\n            \"readOnly\": true\n          },\n          { \n            \"name\": \"kubernetes-key-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/kubernetes-key.pem\",\n            \"readOnly\": true\n          },\n          { \n            \"name\": \"proxy-client-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/proxy-client.pem\",\n            \"readOnly\": true\n          },\n          { \n            \"name\": \"proxy-client-key-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/proxy-client-key.pem\",\n            \"readOnly\": true\n          },\n          {\n            \"name\": \"ca-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/ca.pem\",\n            \"readOnly\": true\n          }\n        ]\n      }\n    ],\n    \"volumes\":[\n      { \n        \"name\": \"encryption-config\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/config/encryption-config.yaml\"\n        }\n      },\n      { \n        \"name\": \"audit-policy-config\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/config/audit-policy.yaml\"\n        }\n      },\n      { \n        \"name\": \"apiserver-logfile\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/log/kube-apiserver.log\",\n          \"type\": \"FileOrCreate\"\n        }\n      },\n      { \n        \"name\": \"audit-logfile\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/log/kube-apiserver-audit.log\",\n          \"type\": \"FileOrCreate\"\n        }\n      },\n      { \n        \"name\": \"kubernetes-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/kubernetes.pem\"\n        }\n      },\n      { \n        \"name\": \"kubernetes-key-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/kubernetes-key.pem\"\n        }\n      },\n      { \n        \"name\": \"proxy-client-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/proxy-client.pem\"\n        }\n      },\n      { \n        \"name\": \"proxy-client-key-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/proxy-client-key.pem\"\n        }\n      },\n      { \n        \"name\": \"ca-pem\",\n          \"hostPath\": {\n            \"path\": \"{{k8s_cluster_root}}/ssl/ca.pem\"\n          }\n      }\n    ]\n  }\n}\n```','k8s,apiserver','admin','2019-12-23 15:16:19',2),(4,'kubernetes kube-controller-manager.json','# kube-controller-manager.json\n```yml\n{\n  \"apiVersion\": \"v1\",\n  \"kind\": \"Pod\",\n  \"metadata\": {\n    \"name\":\"kube-controller-manager\",\n    \"namespace\": \"kube-system\",\n    \"annotations\": {\n      \"scheduler.alpha.kubernetes.io/critical-pod\": \"\",\n      \"seccomp.security.alpha.kubernetes.io/pod\": \"docker/default\"\n    },\n    \"labels\": {\n      \"tier\": \"control-plane\",\n      \"component\": \"kube-controller-manager\",\n      \"type.pod.kubernetes.io\": \"system\"\n    }\n  },\n  \"spec\":{\n    \"hostNetwork\": true,\n    \"containers\":[\n      {\n        \"name\": \"kube-controller-manager\",\n        \"image\": \"{{kube_controller_manager_images}}\",\n        \"resources\": {\n          \"requests\": {\n            \"cpu\": \"{{kube_controller_manager_request_cpu}}\",\n            \"memory\": \"{{kube_controller_managerrequest_memory}}\"\n          },\n          \"limits\": {\n            \"cpu\": \"{{kube_controller_manager_limit_cpu}}\",\n            \"memory\": \"{{kube_controller_manager_limit_memory}}\"\n          }\n        },\n        \"livenessProbe\": {\n          \"httpGet\": {\n            \"host\": \"127.0.0.1\",\n            \"port\": 10252,\n            \"path\": \"/healthz\"\n          },\n          \"initialDelaySeconds\": 15,\n          \"timeoutSeconds\": 15\n        },\n        \"command\": [\n          \"/bin/sh\",\n          \"-c\",\n          \"exec /usr/local/bin/kube-controller-manager --profiling --allocate-node-cidrs=true --cluster-cidr=${CLUSTER_POD_CIDR} --cluster-name=kubernetes --controllers=*,bootstrapsigner,tokencleaner --kube-api-qps=1000 --kube-api-burst=2000 --leader-elect --use-service-account-credentials --concurrent-service-syncs=2 --bind-address={{ansible_host}} --address=127.0.0.1 --secure-port=10252 --tls-cert-file=/etc/kubernetes/ssl/kube-controller-manager.pem --tls-private-key-file=/etc/kubernetes/ssl/kube-controller-manager-key.pem --authentication-kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig --client-ca-file=/etc/kubernetes/ssl/ca.pem --requestheader-allowed-names=\\\"\\\" --requestheader-client-ca-file=/etc/kubernetes/ssl/ca.pem --requestheader-extra-headers-prefix=\\\"X-Remote-Extra-\\\" --requestheader-group-headers=X-Remote-Group --requestheader-username-headers=X-Remote-User --authorization-kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig --cluster-signing-cert-file=/etc/kubernetes/ssl/ca.pem --cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem --experimental-cluster-signing-duration=876000h --horizontal-pod-autoscaler-sync-period=10s --concurrent-deployment-syncs=10 --concurrent-gc-syncs=30 --node-cidr-mask-size=24 --service-cluster-ip-range={{cluster_service_ip_range}} --pod-eviction-timeout=6m --terminated-pod-gc-threshold=10000 --root-ca-file=/etc/kubernetes/certs/ca.pem --service-account-private-key-file=/etc/kubernetes/certs/ca-key.pem --kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig --v=3 1>>/var/log/kube-controller-manager.log 2>&1\"\n        ],\n        \"volumeMounts\": [\n          { \n            \"name\": \"ca-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/ca.pem\",\n            \"readOnly\": true\n          },\n          {\n            \"name\": \"ca-key-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/ca-key.pem\",\n            \"readOnly\": true\n          },\n          { \n            \"name\": \"kube-controller-manager-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/kube-controller-manager.pem\",\n            \"readOnly\": true\n          },\n          {\n            \"name\": \"kube-controller-manager-key-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/kube-controller-manager-key.pem\",\n            \"readOnly\": true\n          },\n          { \n            \"name\": \"kube-controller-manager-logfile\",\n            \"mountPath\": \"/var/log/kube-controller-manager.log\",\n            \"readOnly\": false\n          },\n          { \n            \"name\": \"kube-controller-manager-config\",\n            \"mountPath\": \"/etc/kubernetes/kube-controller-manager.kubeconfig\",\n            \"readOnly\": true\n          }\n        ]\n      }\n    ],\n    \"volumes\":[\n      { \n        \"name\": \"ca-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/ca.pem\"\n        }\n      },\n      { \n        \"name\": \"ca-key-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/ca-key.pem\"\n        }\n      },\n      { \n        \"name\": \"kube-controller-manager-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/kube-controller-manager.pem\"\n        }\n      },\n      { \n        \"name\": \"kube-controller-manager-key-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/kube-controller-manager-key.pem\"\n        }\n      },\n      { \n        \"name\": \"kube-controller-manager-logfile\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/logs/kube-controller-manager.log\",\n          \"type\": \"FileOrCreate\"\n        }\n      },\n      { \n        \"name\": \"kube-controller-manager-config\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/config/kube-controller-manager.kubeconfig\"\n        }\n      }\n    ]\n  }\n}\n```','k8s,kube-controller-manager','admin','2019-12-23 16:22:45',2),(5,'kubernetes kube-scheduler.json','# kube-scheduler.json\n```yml\n{\n  \"apiVersion\": \"v1\",\n  \"kind\": \"Pod\",\n  \"metadata\": {\n    \"name\":\"kube-scheduler\",\n    \"namespace\": \"kube-system\",\n    \"annotations\": {\n      \"scheduler.alpha.kubernetes.io/critical-pod\": \"\",\n      \"seccomp.security.alpha.kubernetes.io/pod\": \"docker/default\"\n    },\n    \"labels\": {\n      \"tier\": \"control-plane\",\n      \"component\": \"kube-scheduler\",\n      \"type.pod.kubernetes.io\": \"system\"\n    }\n  },\n  \"spec\":{\n    \"hostNetwork\": true,\n    \"containers\":[\n      {\n        \"name\": \"kube-scheduler\",\n        \"image\": \"{{kube_scheduler_images}}\",\n        \"resources\": {\n          \"requests\": {\n            \"cpu\": \"{{kube_scheduler_request_cpu}}\",\n            \"memory\": \"{{kube_scheduler_request_memory}}\"\n          },\n          \"limits\": {\n            \"cpu\": \"{{kube_scheduler_limit_cpu}}\",\n            \"memory\": \"{{kube_scheduler_limit_memory}}\"\n          }\n        },\n        \"livenessProbe\": {\n          \"httpGet\": {\n            \"host\": \"127.0.0.1\",\n            \"port\": 10251,\n            \"path\": \"/healthz\"\n          },\n          \"initialDelaySeconds\": 15,\n          \"timeoutSeconds\": 15\n        },\n        \"command\": [\n          \"/bin/sh\",\n          \"-c\",\n          \"exec /usr/local/bin/kube-scheduler --config=/etc/kubernetes/kube-scheduler.yaml --bind-address={{ansible_host}} --secure-port=10259 --port=0 --tls-cert-file=/etc/kubernetes/ssl/kube-scheduler.pem --tls-private-key-file=/etc/kubernetes/ssl/kube-scheduler-key.pem --authentication-kubeconfig=/etc/kubernetes/kube-scheduler.kubeconfig --client-ca-file=/etc/kubernetes/ssl/ca.pem --requestheader-allowed-names=\\\"\\\" --requestheader-client-ca-file=/etc/kubernetes/ssl/ca.pem --requestheader-extra-headers-prefix=\\\"X-Remote-Extra-\\\" --requestheader-group-headers=X-Remote-Group --requestheader-username-headers=X-Remote-User --authorization-kubeconfig=/etc/kubernetes/kube-scheduler.kubeconfig --v=3 1>>/var/log/kube-scheduler.log 2>&1\"\n        ],\n        \"volumeMounts\": [\n          {\n            \"name\": \"kube-scheduler-logfile\",\n            \"mountPath\": \"/var/log/kube-scheduler.log\",\n            \"readOnly\": false\n          },\n          {\n            \"name\": \"kube-scheduler-kubeconfig\",\n            \"mountPath\": \"/etc/kubernetes/kube-scheduler.kubeconfig\",\n            \"readOnly\": true\n          },\n          {\n            \"name\": \"kube-scheduler-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/kube-scheduler.pem\",\n            \"readOnly\": true\n          },\n          {\n            \"name\": \"kube-scheduler-key-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/kube-scheduler-key.pem\",\n            \"readOnly\": true\n          },\n          {\n            \"name\": \"ca-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/ca.pem\",\n            \"readOnly\": true\n          },\n          {\n            \"name\": \"kube-scheduler-config\",\n            \"mountPath\": \"/etc/kubernetes/kube-scheduler.yaml\",\n            \"readOnly\": true\n          }\n        ]\n      }\n    ],\n    \"volumes\":[\n      {\n        \"name\": \"kube-scheduler-logfile\",\n        \"hostPath\": {\"path\": \"{{k8s_cluster_root}}/logs/kube-scheduler.log\"}\n      },\n      {\n        \"name\": \"kube-scheduler-kubeconfig\",\n        \"hostPath\": {\"path\": \"{{k8s_cluster_root}}/config/kube-scheduler.kubeconfig\"}\n      },\n      {\n        \"name\": \"kube-scheduler-pem\",\n        \"hostPath\": {\"path\": \"{{k8s_cluster_root}}/ssl/kube-scheduler.pem\"}\n      },\n      {\n        \"name\": \"kube-scheduler-key-pem\",\n        \"hostPath\": {\"path\": \"{{k8s_cluster_root}}/ssl/kube-scheduler-key.pem\"}\n      },\n      {\n        \"name\": \"ca-pem\",\n        \"hostPath\": {\"path\": \"{{k8s_cluster_root}}/ssl/ca.pem\"}\n      },\n      {\n        \"name\": \"kube-scheduler-config\",\n        \"hostPath\": {\"path\": \"{{k8s_cluster_root}}/config/kube-scheduler.yaml\"}\n      }\n    ]\n  }\n}\n```','k8s,kube-scheduler','admin','2019-12-23 16:54:03',2),(6,'kubernetes v1.16.2镜像列表','# kubernetes v1.16.2镜像列表\n## etcd\n```\nregistry.cn-hangzhou.aliyuncs.com/kubernetes_v1_16_2/etcd:v3.3.13\n```\n## kube-apiserve\n```\nregistry.cn-hangzhou.aliyuncs.com/kubernetes_v1_16_2/kube-apiserver:v1.16.2\n```\n## kube-controller-manager\n```\nregistry.cn-hangzhou.aliyuncs.com/kubernetes_v1_16_2/kube-controller-manager:v1.16.2\n```\n## kube-scheduler\n```\nregistry.cn-hangzhou.aliyuncs.com/kubernetes_v1_16_2/kube-scheduler:v1.16.2\n```\n## flannel\n```\nregistry.cn-hangzhou.aliyuncs.com/kubernetes_v1_16_2/flannel:v0.11.0-amd64\n```\n## kube-api-proxy\n```\nregistry.cn-hangzhou.aliyuncs.com/kubernetes_v1_16_2/kube-api-proxy:v1.16.2\n```\n### images\n```\ndocker pull bluersw/kube-apiserver:v1.16.2 #替代docker pull k8s.gcr.io/kube-apiserver:v1.16.2\ndocker tag bluersw/kube-apiserver:v1.16.2 k8s.gcr.io/kube-apiserver:v1.16.2\n\ndocker pull bluersw/kube-controller-manager:v1.16.2 #替代docker pull k8s.gcr.io/kube-controller-manager:v1.16.2\ndocker tag bluersw/kube-controller-manager:v1.16.2 k8s.gcr.io/kube-controller-manager:v1.16.2\n\ndocker pull bluersw/kube-scheduler:v1.16.2 #替代docker pull k8s.gcr.io/kube-scheduler:v1.16.2\ndocker tag bluersw/kube-scheduler:v1.16.2 k8s.gcr.io/kube-scheduler:v1.16.2\n\ndocker pull bluersw/kube-proxy:v1.16.2 #替代docker pull k8s.gcr.io/kube-proxy:v1.16.2\ndocker tag bluersw/kube-proxy:v1.16.2 k8s.gcr.io/kube-proxy:v1.16.2\n\ndocker pull bluersw/pause:3.1 #替代docker pull k8s.gcr.io/pause:3.1\ndocker tag bluersw/pause:3.1 k8s.gcr.io/pause:3.1\n\ndocker pull bluersw/etcd:3.3.15-0 #替代docker pull k8s.gcr.io/etcd:3.3.15-0\ndocker tag bluersw/etcd:3.3.15-0 k8s.gcr.io/etcd:3.3.15-0\n\ndocker pull bluersw/coredns:1.6.2 #替代docker pull k8s.gcr.io/coredns:1.6.2\ndocker tag bluersw/coredns:1.6.2 k8s.gcr.io/coredns:1.6.2\n\ndocker pull bluersw/flannel:v0.11.0-amd64 #替代 docker pull quay.io/coreos/flannel:v0.11.0-amd64\ndocker tag bluersw/flannel:v0.11.0-amd64 quay.io/coreos/flannel:v0.11.0-amd64\n```','k8s,images','admin','2019-12-23 19:59:02',2),(7,'kubernetes变量列表','# kubernetes变量列表\n```yml\n\n```','k8s,变量','admin','2019-12-23 20:23:32',2),(8,'test','# init system config\n\n```yml\n- name: disabled selinux\n  selinux:\n    state: disabled\n- name: disabled selinux\n  command: setenforce 0\n- name: stop firewalld\n  systemd:\n    name: firewalld\n    state: stopped\n    enabled: no\n\n```','test','admin','2019-12-24 10:51:56',2),(9,'install docker','# install docker\n```yml\n- name: download docker bin file\n  get_url:\n    url: \"{{docker_download_url}}\"\n    dest: /tmp/{{docker_version}}.tgz\n- name: unarchive docker bin file\n  unarchive:\n    copy: no\n    src: \"/tmp/{{docker_version}}.tgz\"\n    dest: /usr/local/bin/\n- name: cp docker service\n  template:\n    src: \"{{ansible_root_dir}}/roles/docker/templates/docker.service.j2\"\n    dest: /etc/systemd/system/docker.service\n    owner: root\n    group: root\n    mode: 0644\n- name: create docker dir\n  file:\n    path: /etc/docker\n    state: directory\n    mode: \'0755\'\n- name: cp root cert\n  copy:\n    src: \"{{ansible_root_dir}}/certs/ca.pem\"\n    dest: /etc/docker/ca.pem\n    owner: root\n    group: root\n    mode: 0644\n- name: cp docker cert key\n  copy:\n    src: \"{{ansible_root_dir}}/certs/docker-key.pem\"\n    dest: /etc/docker/docker-key.pem\n    owner: root\n    group: root\n    mode: 0644\n- name: cp docker cert\n  copy:\n    src: \"{{ansible_root_dir}}/certs/docker.pem\"\n    dest: /etc/docker/docker.pem\n    owner: root\n    group: root\n    mode: 0644\n- name: systemctl daemon reload\n  command: systemctl daemon-reload\n- name: docker runc protect\n  command: chattr +i /usr/local/bin/runc\n- name: start docker service\n  service:\n    name: docker\n    state: started\n    enabled: yes\n- name: get docker status\n  command: systemctl status docker\n  register: docker_status\n  failed_when: docker_status.stdout.find(\"(running)\") == -1\n\n```','docker','admin','2019-12-24 11:10:38',2),(10,'uninstall docker','# uninstall docker\n```yml\n- name: stop/disable docker service\n  service:\n    name: docker\n    state: stoped\n    enabled: no\n- name: create bak dir\n  file:\n    path: /tmp/dockerbak\n    state: directory\n    mode: \'0755\'\n- name: move bin file to bak\n  command: mv /usr/local/bin/{{item}} /tmp/dockerbak/\n  with_items:\n    - [\"containerd\",\"containerd-shim\",\"ctr\",\"docker\",\"dockerd\",\"docker-init\",\"docker-proxy\",\"runc\"]\n- name: move servicefile to bak\n  command: mv /etc/systemd/system/docker.service /tmp/dockerbak/\n- name: move docker certs to bak\n  command: mv /etc/docker/{{item}} /tmp/dockerbak/\n  with_items:\n    - \"ca.pem\"\n    - \"docker.pem\"\n    - \"docker-key.pem\"\n```','docker','admin','2019-12-24 11:11:43',2),(11,'build-certs.sh','# build-certs.sh\n```shell\n#!/usr/bin/env bash\n# build k8s certs\n\nCERT_DIR=$1\nKUBE_API_IP=$2\n\ntouch ~/.rnd\nmkdir -p ${CERT_DIR}\ncd ${CERT_DIR}\ncat > openssl.cnf <<EOF\n[ req ]\nreq_extensions = v3_req\ndistinguished_name = req_distinguished_name\n[ req_distinguished_name ]\n[ v3_req ]\nbasicConstraints = CA:FALSE\nkeyUsage = nonRepudiation, digitalSignature, keyEncipherment\nsubjectAltName = @alt_names\n[ alt_names ]\nDNS.1 = kubernetes\nDNS.2 = kubernetes.default\nDNS.3 = kubernetes.default.svc\nDNS.4 = kubernetes.default.svc.cluster\nDNS.5 = kubernetes.default.svc.cluster.local\nIP.1 = ${KUBE_API_IP}\nEOF\n\n# ca cert\nopenssl genrsa -out ca-key.pem 2048\nopenssl req -x509 -new -nodes -key ca-key.pem -days 10000 -out ca.pem -subj \"/CN=kubernetes/O=k8s\"\n\n# docker cert\nopenssl genrsa -out docker-key.pem 2048\nopenssl req -new -key docker-key.pem -out docker.csr -subj \"/CN=docker\"\nopenssl x509 -req -in docker.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out docker.pem -days 10000\n\n# etcd cert\nopenssl genrsa -out etcd-key.pem 2048\nopenssl req -new -key etcd-key.pem -out etcd.csr -subj \"/CN=etcd\"\nopenssl x509 -req -in etcd.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out etcd.pem -days 10000\n\n# flannel cert\nopenssl genrsa -out flanneld-key.pem 2048\nopenssl req -new -key flanneld-key.pem -out flanneld.csr -subj \"/CN=flanneld\"\nopenssl x509 -req -in flanneld.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out flanneld.pem -days 10000\n\n# admin cert\nopenssl genrsa -out admin-key.pem 2048\nopenssl req -new -key admin-key.pem -out admin.csr -subj \"/CN=admin/O=system:masters\"\nopenssl x509 -req -in admin.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out admin.pem -days 10000\n\n# kubeapiserver cert\nopenssl genrsa -out kubernetes-key.pem 2048\nopenssl req -new -key kubernetes-key.pem -out kubernetes.csr -subj \"/CN=kubernetes/O=k8s\" -config ${CERT_DIR}openssl.cnf\nopenssl x509 -req -in kubernetes.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out kubernetes.pem -days 10000 -extensions v3_req -extfile ${CERT_DIR}openssl.cnf\n\n# kube-scheduler cert\nopenssl genrsa -out kube-scheduler-key.pem 2048\nopenssl req -new -key kube-scheduler-key.pem -out kube-scheduler.csr -subj \"/CN=system:kube-scheduler/O=system:kube-scheduler\"\nopenssl x509 -req -in kube-scheduler.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out kube-scheduler.pem -days 10000\n\n# kube-controller-manager cert\nopenssl genrsa -out kube-controller-manager-key.pem 2048\nopenssl req -new -key kube-controller-manager-key.pem -out kube-controller-manager.csr -subj \"/CN=system:kube-controller-manager/O=system:kube-controller-manager\"\nopenssl x509 -req -in kube-controller-manager.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out kube-controller-manager.pem -days 10000\n\n# kube-proxy cert\nopenssl genrsa -out kube-proxy-key.pem 2048\nopenssl req -new -key kube-proxy-key.pem -out kube-proxy.csr -subj \"/CN=system:kube-proxy/O=k8s\"\nopenssl x509 -req -in kube-proxy.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out kube-proxy.pem -days 10000\n\n# kubelet cert\nopenssl genrsa -out kubelet-key.pem 2048\nopenssl req -new -key kubelet-key.pem -out kubelet.csr -subj \"/CN=system:kubelet/O=k8s\"\nopenssl x509 -req -in kubelet.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out kubelet.pem -days 10000\n```','build certs','admin','2019-12-24 19:28:05',2),(12,'docker.service.j2','# docker.service\n```\n[Unit]\nDescription=Docker Application Container Engine\nDocumentation=http://docs.docker.com\nAfter=network-online.target\n\n[Service]\nDelegate=yes\nType=notify\nKillMode=process\nExecStart=/usr/local/bin/dockerd --live-restore --insecure-registry 192.168.10.20:5000 --tlsverify --tlscacert=/etc/docker/ca.pem --tlscert=/etc/docker/docker.pem --tlskey=/etc/docker/docker-key.pem -H unix:///var/run/docker.sock -H 0.0.0.0:2376\n#MountFlags=share\nRestart=on-failure\nRestartSec=5\nLimitNOFILE=1048576\nLimitNPROC=1048576\nLimitCORE=infinity\n#timeoutStartSec=0\nExecReload=/bin/kill -s HUP $MAINPID\n\n[Install]\nWantedBy=multi-user.target\n```','docker','admin','2019-12-24 19:44:59',2),(13,'docker sysctl.conf','# sysctl.conf\n```\ncat <<EOF > /etc/sysctl.d/k8s.conf\n# https://github.com/moby/moby/issues/31208 \n# ipvsadm -l --timout\n# 修复ipvs模式下长连接timeout问题 小于900即可\nnet.ipv4.tcp_keepalive_time = 600\nnet.ipv4.tcp_keepalive_intvl = 30\nnet.ipv4.tcp_keepalive_probes = 10\nnet.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1\nnet.ipv4.neigh.default.gc_stale_time = 120\nnet.ipv4.conf.all.rp_filter = 0\nnet.ipv4.conf.default.rp_filter = 0\nnet.ipv4.conf.default.arp_announce = 2\nnet.ipv4.conf.lo.arp_announce = 2\nnet.ipv4.conf.all.arp_announce = 2\nnet.ipv4.ip_forward = 1\nnet.ipv4.tcp_max_tw_buckets = 5000\nnet.ipv4.tcp_syncookies = 1\nnet.ipv4.tcp_max_syn_backlog = 1024\nnet.ipv4.tcp_synack_retries = 2\nnet.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1\nnet.netfilter.nf_conntrack_max = 2310720\nfs.inotify.max_user_watches=89100\nfs.may_detach_mounts = 1\nfs.file-max = 52706963\nfs.nr_open = 52706963\nnet.bridge.bridge-nf-call-arptables = 1\nvm.swappiness = 0\nvm.overcommit_memory=1\nvm.panic_on_oom=0\nEOF\n```','sysctl.conf','admin','2019-12-24 20:05:26',2);
/*!40000 ALTER TABLE `documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group_permission`
--

DROP TABLE IF EXISTS `group_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_permission` (
  `group_id` int(11) DEFAULT NULL,
  `permission_id` int(11) DEFAULT NULL,
  KEY `group_id` (`group_id`),
  KEY `permission_id` (`permission_id`),
  CONSTRAINT `group_permission_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`),
  CONSTRAINT `group_permission_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_permission`
--

LOCK TABLES `group_permission` WRITE;
/*!40000 ALTER TABLE `group_permission` DISABLE KEYS */;
/*!40000 ALTER TABLE `group_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group_role`
--

DROP TABLE IF EXISTS `group_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_role` (
  `group_id` int(11) DEFAULT NULL,
  `role_id` int(11) DEFAULT NULL,
  KEY `group_id` (`group_id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `group_role_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`),
  CONSTRAINT `group_role_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_role`
--

LOCK TABLES `group_role` WRITE;
/*!40000 ALTER TABLE `group_role` DISABLE KEYS */;
/*!40000 ALTER TABLE `group_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(16) NOT NULL,
  `desc` varchar(255) NOT NULL,
  `ctime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `groups`
--

LOCK TABLES `groups` WRITE;
/*!40000 ALTER TABLE `groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `desc` varchar(255) NOT NULL,
  `ctime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=607 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
INSERT INTO `permissions` VALUES (101,'user_add','添加用户','2019-12-23 10:25:34'),(102,'user_delete','删除用户','2019-12-23 10:25:34'),(103,'user_update_owner','更新个人信息','2019-12-23 10:25:34'),(104,'user_update_all','更新用户信息','2019-12-23 10:25:34'),(105,'user_modify','修改用户','2019-12-23 10:25:34'),(106,'user_get_owner','查看个人信息','2019-12-23 10:25:34'),(107,'user_get_list','查看所有用户信息和列表','2019-12-23 10:25:34'),(201,'group_add','添加用户组','2019-12-23 10:25:35'),(202,'group_delete','删除用户组','2019-12-23 10:25:35'),(203,'group_update','更新用户组','2019-12-23 10:25:35'),(204,'group_modify','修改用户组','2019-12-23 10:25:35'),(205,'group_get_list','查看用户组和用户组列表','2019-12-23 10:25:35'),(301,'role_add','添加角色','2019-12-23 10:25:35'),(302,'role_delete','删除角色','2019-12-23 10:25:35'),(303,'role_update','更新角色','2019-12-23 10:25:35'),(304,'role_modify','修改角色','2019-12-23 10:25:35'),(305,'role_get_list','查看角色和角色列表','2019-12-23 10:25:35'),(401,'permission_get_list','查看权限和权限列表','2019-12-23 10:25:35'),(501,'dashboard','查看dashboard','2019-12-23 10:25:35'),(601,'server_add','添加服务器','2019-12-23 10:25:35'),(602,'server_delete','删除服务器','2019-12-23 10:25:35'),(603,'server_update','更新服务器','2019-12-23 10:25:35'),(604,'server_modify','修改服务器','2019-12-23 10:25:35'),(605,'server_get','查看服务器列表','2019-12-23 10:25:35'),(606,'server_webssh','服务器webssh','2019-12-23 10:25:35');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permission`
--

DROP TABLE IF EXISTS `role_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role_permission` (
  `role_id` int(11) DEFAULT NULL,
  `permission_id` int(11) DEFAULT NULL,
  KEY `role_id` (`role_id`),
  KEY `permission_id` (`permission_id`),
  CONSTRAINT `role_permission_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`),
  CONSTRAINT `role_permission_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permission`
--

LOCK TABLES `role_permission` WRITE;
/*!40000 ALTER TABLE `role_permission` DISABLE KEYS */;
INSERT INTO `role_permission` VALUES (1,101),(1,102),(1,103),(1,104),(1,105),(1,106),(1,107),(1,201),(1,202),(1,203),(1,204),(1,205),(1,305),(1,501),(2,103),(2,106),(2,501);
/*!40000 ALTER TABLE `role_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `desc` varchar(255) NOT NULL,
  `ctime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'账户管理员','账户管理者,可以对用户/用户组进行增删改查操作','2019-12-23 10:25:35'),(2,'系统默认角色','所有用户都应该拥有该角色','2019-12-23 10:25:35');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `servers`
--

DROP TABLE IF EXISTS `servers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `servers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ip` varchar(32) NOT NULL,
  `port` int(11) DEFAULT NULL,
  `username` varchar(16) NOT NULL,
  `password` varchar(1024) NOT NULL,
  `desc` varchar(255) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `zone` varchar(50) NOT NULL,
  `ctime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ip` (`ip`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `servers`
--

LOCK TABLES `servers` WRITE;
/*!40000 ALTER TABLE `servers` DISABLE KEYS */;
INSERT INTO `servers` VALUES (2,'192.168.10.20',22,'root','6d2eda21fd05942e347cc2f8751029caf3e48bd2070c0a6875aa68b1c9c20acbddb0eb00497b6e133c00916192099e47aabc10e80bd81ce1510b867ce59854e3dcd76cd8003dc649b3c8d1c8d2d1bf21b687b8074aa9640ea80e1c2fd04ef18575c39d7d30d42fd803d2212acc0d91b7c724628cd6e57c8b649386f10fac4116507596f1b9599f1ec28b61f381797850068cc3c0b01695e4faffa271672e1f077761aff26d8768da9756dee2dc0805ddf95ba49ba3e4ac80c712e70eadb9ab39dde484547e573f127b9405c548a59acc16205875a14736c5776beb21759a2328507c879e8fa5a6f528da039adebc35e6beed82834462029d18b3ca620d01a21d','master-1',1,'local','2019-12-23 18:48:55'),(3,'192.168.10.60',22,'root','006a7bb4c700c193d825ba60d9913149b1fd84a6d4b05c854ac84b1899d89e05134999d20438abd79387d87745084af581effe227a417f063b2c91d8819b4aa9df1ec01aab19864665c1084fd5ed9f8232c3b2fd17b45e629191180bd2df4ae668add26a749e23123cb1a27dfe3a3b4c56dcb491e137c7818d1cb498f3c5fa92e4e1a3240b73c02c0850d7e374e787ec6a7f34e94c3757a6d97c97c79e3ff74e2959ecff935ced8e1b0c5d9e82ce9d60e06beb4518a7876041c99e2e0036dfa7160d151ee5351f1649f32016666959bb71b456902b5107ee6b42bfa6838a991639413552afe4885e29ab0bc01f344276afcaa3708b2dc09953c713ebb2f07749','',1,'local','2019-12-23 18:49:10'),(4,'127.0.0.1',22,'root','1efd9ad944061cfcf37e03e1eb70c3cbb9536499524dd94db16146601453662bb672fec27d5a0cf29074b1d1a4d0904309b2deae0840517678e194f093b88013a07d2ac6e3121a6d1763f604269839531cc999dcc8a7a3b3db3eab754a6de5a771b719221bfbe9b15cc3a5282b0ba165d05346d4a6f6b3b5e8767ae9cd7b51ec6196911fa2edc46a9773f0cbd4f7249e2bd5e21153fec76d9619873695ba341a5ada7420d4f59d6cc0e77b882d2e86276ab8f0f30cea2b2a74bc5b35168f2deffde7df8189a629f317bf4fd96d2e264889dd3cfc4445bc312ff65d560f9c6e898f775365ccca110634d8bfd73d75fd074ede76c065126bc55e58729c7c0c13a3','test',1,'local','2019-12-24 10:47:46'),(5,'198.11.177.175',22,'root','838dce9ed3eef5e2b45302bf9326444118f81ef41436938c0883e7e8e149b5e565df4c0e812e27deac3bbb2839a81f5b3622fe3a2ad63d5c39dd4925a8556c3cb4e4e428aab1e8318714d6d0dcd81c3ecc20596b99914189597041cfaa1c01652952696d911935e101e19cd95ba087c4fc38e7eb2fe5610a6d9b4f8d8af7471b90e473d5e76b0bf9100b6b50b93b3c4e591021270ecadbad9a4f4391145d115fd8a8c853ea316ad5fa56b30cb2fc40053a2b07e137cc917acb15ef042dfb80462af93ad87f3f2c60936f249289a28cff5cf6d2fda56b323ef99bf61dd9ffe3326dceb9d4ef5e9ea4f00282276fa4c4597a067053868b5e9170dd79e017b88f46','test',1,'local','2019-12-24 15:39:28'),(7,'47.112.49.137',22,'root','d8f9758d2e8493dabfd5e9eb58516ef80c30d75269eae0d29a92f92dde7cbaff5cb2a271d3db1aff7e4762c758cab2a8a8c9508cc3624aa546eef9b31a699747dfda48d72233e4ea76f9e963d2121cd23c49c48212a2f85b9562d0cc3686c32b792f5a97ff6f6e1c9bf8a6bc5ef294fced6f84da9366b596853e3c44180b51ca58527fc38e9b8c2eff78f4693453130b3761107e33982bfd8ff73a28cb17300036e474c5026901e1e3f421e2a4216182abdfb311f673db4c45b68c42e30eb9e155250f26e90b96bbce900a90bafa3880fcff70bd85d095a79e00805e8d0d46e0c2c90a2d0316531fbc3f4913af6ca6dbfe069c0ffb6e1fbd38bae05cb6194594','',1,'local','2019-12-24 19:02:23');
/*!40000 ALTER TABLE `servers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_group`
--

DROP TABLE IF EXISTS `user_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_group` (
  `user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  KEY `user_id` (`user_id`),
  KEY `group_id` (`group_id`),
  CONSTRAINT `user_group_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `user_group_ibfk_2` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_group`
--

LOCK TABLES `user_group` WRITE;
/*!40000 ALTER TABLE `user_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_permission`
--

DROP TABLE IF EXISTS `user_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_permission` (
  `user_id` int(11) DEFAULT NULL,
  `permission_id` int(11) DEFAULT NULL,
  KEY `user_id` (`user_id`),
  KEY `permission_id` (`permission_id`),
  CONSTRAINT `user_permission_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `user_permission_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_permission`
--

LOCK TABLES `user_permission` WRITE;
/*!40000 ALTER TABLE `user_permission` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_role`
--

DROP TABLE IF EXISTS `user_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_role` (
  `user_id` int(11) DEFAULT NULL,
  `role_id` int(11) DEFAULT NULL,
  KEY `user_id` (`user_id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `user_role_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `user_role_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_role`
--

LOCK TABLES `user_role` WRITE;
/*!40000 ALTER TABLE `user_role` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(16) NOT NULL,
  `cname` varchar(16) NOT NULL,
  `pwd_hash` varchar(100) NOT NULL,
  `is_super` tinyint(1) DEFAULT NULL,
  `status` tinyint(1) DEFAULT NULL,
  `phone_number` varchar(11) NOT NULL,
  `email` varchar(32) NOT NULL,
  `access_token` varchar(32) DEFAULT NULL,
  `token_expired` int(11) DEFAULT NULL,
  `ctime` datetime DEFAULT NULL,
  `login_time` datetime DEFAULT NULL,
  `last_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `cname` (`cname`),
  UNIQUE KEY `phone_number` (`phone_number`),
  UNIQUE KEY `email` (`email`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`is_super` in (0,1)),
  CONSTRAINT `CONSTRAINT_2` CHECK (`status` in (0,1))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','admin','pbkdf2:sha256:150000$ymlosmY7$184ddd6854ef11252a8a0f5b78511773548bb5e9ccf7460360d936d4b72e8bf1',1,1,'13888888888','admin@admin.com','479cfe9bfaab4ae7939a0bbc3db2483e',1577228966,'2019-12-23 10:25:35','2019-12-24 19:00:46','2019-12-24 09:34:56');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-12-24 23:10:05
