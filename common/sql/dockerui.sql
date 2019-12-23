-- MySQL dump 10.13  Distrib 5.7.28, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: dockerui
-- ------------------------------------------------------
-- Server version	5.5.5-10.4.10-MariaDB-1:10.4.10+maria~bionic

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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents`
--

LOCK TABLES `documents` WRITE;
/*!40000 ALTER TABLE `documents` DISABLE KEYS */;
INSERT INTO `documents` VALUES (1,'test','# test\n```python\ndef test(msg):\n  print(msg)\n```\n## this is a test for python','test','admin','2019-12-23 10:28:13',1),(2,'kubernetes etcd.json','# etcd.json\n```yml\n{\n  \"apiVersion\": \"v1\",\n  \"kind\": \"Pod\",\n  \"metadata\": {\n    \"name\":\"kube-etcd\",\n    \"namespace\": \"kube-system\",\n    \"annotations\": {\n      \"scheduler.alpha.kubernetes.io/critical-pod\": \"\",\n      \"seccomp.security.alpha.kubernetes.io/pod\": \"docker/default\"\n     }\n  },\n  \"spec\": {\n    \"hostNetwork\": true,\n    \"containers\":[{\n      \"name\": \"kube-etcd\",\n      \"image\": \"{{etcd_images}}\",\n      \"resources\": {\n        \"requests\": {\n          \"cpu\": \"{{etcd_request_cpu}}\",\n          \"memory\": \"{{etcd_request_memory}}\"\n        },\n        \"limits\": {\n          \"cpu\": \"{{etcd_limit_cpu}}\",\n          \"memory\": \"{{etcd_limit_memory}}\"\n        }\n      },\n      \"livenessProbe\": {\n        \"exec\": {\n          \"command\": [\"/bin/sh\", \"-ec\", \"ETCDCTL_API=3 etcdctl --endpoints=127.0.0.1:2379 get foo\"]\n        },\n        \"failureThreshold\": 8,\n        \"initialDelaySeconds\": 15,\n        \"timeoutSeconds\": 15\n      },\n      \"command\": [\n        \"/bin/sh\",\n        \"-c\",\n        \"if [ -e /usr/local/bin/migrate-if-needed.sh ]; then /usr/local/bin/migrate-if-needed.sh 1>>/var/log/etcd.log 2>&1; fi; exec /usr/local/bin/etcd --data-dir=/var/lib/etcd/data --name=kube-etcd-{{index}} --cert-file=/etc/ssl/etcd.pem --key-file=/etc/ssl/etcd-key.pem --trusted-ca-file=/etc/ssl/ca.pem --peer-cert-file=/etc/ssl/etcd.pem --peer-key-file=/etc/ssl/etcd-key.pem --peer-trusted-ca-file=/etc/ssl/ca.pem --peer-client-cert-auth --client-cert-auth --listen-peer-urls=https://{{ansible_host}}:2380 --initial-advertise-peer-urls=https://{{ansible_host}}:2380 --listen-client-urls=https://{{ansible_host}}:2379,https://127.0.0.1:2379 --advertise-client-urls=https://{{ansible_host}}:2379 --initial-cluster-token=kube-etcd-cluster --initial-cluster={{etcd_cluster}} --initial-cluster-state=new --auto-compaction-mode=periodic --auto-compaction-retention=1 --max-request-bytes=33554432 --quota-backend-bytes=6442450944 --heartbeat-interval=1000 --election-timeout=10000 --snapshot-count=10000 --max-snapshots=5 --max-wals=5 1>>/var/log/etcd.log 2>&1\"\n      ],\n      \"volumeMounts\": [\n        { \n          \"name\": \"etcd-key-pem\",\n          \"mountPath\": \"/etc/ssl/etcd-key.pem\",\n          \"readOnly\": true\n        },\n        { \n          \"name\": \"etcd-pem\",\n          \"mountPath\": \"/etc/ssl/etcd.pem\",\n          \"readOnly\": true\n        },\n        { \n          \"name\": \"ca-pem\",\n          \"mountPath\": \"/etc/ssl/ca.pem\",\n          \"readOnly\": true\n        },\n        { \n          \"name\": \"etcd-log\",\n          \"mountPath\": \"/var/log/etcd.log\",\n          \"readOnly\": false\n        },\n        { \n          \"name\": \"etcd-data\",\n          \"mountPath\": \"/var/lib/etcd/data\",\n          \"readOnly\": false\n        }\n      ]\n    }],\n    \"volumes\":[\n      {\n        \"name\": \"etcd-key-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/etcd-key.pem\"\n        }\n      },\n      { \n        \"name\": \"etcd-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/etcd.pem\"\n        }\n      },\n      {\n        \"name\": \"ca-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/ca.pem\"\n        }\n      },\n      { \n        \"name\": \"etcd-log\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/logs/etcd.log\",\n          \"type\": \"FileOrCreate\"\n        }\n      },\n      { \n        \"name\": \"etcd-data\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/data/etcd\",\n          \"type\": \"DirectoryOrCreate\"\n        }\n      }\n    ]\n  }\n}\n```','k8s,etcd','admin','2019-12-23 11:29:19',2),(3,'kubernetes kube-apiserver.json','# kube-apiserver.json\n```yml\n{\n  \"apiVersion\": \"v1\",\n  \"kind\": \"Pod\",\n  \"metadata\": {\n    \"name\":\"kube-apiserver\",\n    \"namespace\": \"kube-system\",\n    \"annotations\": {\n      \"scheduler.alpha.kubernetes.io/critical-pod\": \"\",\n      \"seccomp.security.alpha.kubernetes.io/pod\": \"docker/default\"\n    },\n    \"labels\": {\n      \"tier\": \"control-plane\",\n      \"component\": \"kube-apiserver\",\n      \"type.pod.kubernetes.io\": \"system\"\n    }\n  },\n  \"spec\":{\n    \"hostNetwork\": true,\n    \"containers\":[\n      {\n        \"name\": \"kube-apiserver\",\n        \"image\": \"{{kube_apiserver_images}}\",\n        \"resources\": {\n          \"requests\": {\n            \"cpu\": \"{{kube_apiserver_request_cpu}}\",\n            \"memory\": \"{{kube_apiserver_request_memory}}\"\n          },\n          \"limits\": {\n            \"cpu\": \"{{kube_apiserver_limit_cpu}}\",\n            \"memory\": \"{{kube_apiserver_limit_memory}}\"\n          }\n        },\n        \"livenessProbe\": {\n          \"httpGet\": {\n            \"scheme\": \"HTTPS\",\n            \"host\": \"127.0.0.1\",\n            \"port\": 6443,\n            \"path\": \"/livez?exclude=etcd&exclude=kms-provider-0&exclude=kms-provider-1\"\n          },\n          \"initialDelaySeconds\": 15,\n          \"timeoutSeconds\": 15\n        },\n        \"command\": [\n           \"/bin/sh\",\n           \"-c\",\n           \"exec /usr/local/bin/kube-apiserver --advertise-address={{ansible_host}} --default-not-ready-toleration-seconds=360 --default-unreachable-toleration-seconds=360 --feature-gates=DynamicAuditing=true --max-mutating-requests-inflight=2000 --max-requests-inflight=4000 --default-watch-cache-size=200 --delete-collection-workers=2 --encryption-provider-config=/etc/kubernetes/encryption-config.yaml --etcd-cafile=/etc/kubernetes/ssl/ca.pem --etcd-certfile=/etc/kubernetes/ssl/kubernetes.pem --etcd-keyfile=/etc/kubernetes/ssl/kubernetes-key.pem --etcd-servers={{etcd_cluster}} --bind-address={{ansible_host}} --secure-port=6443 --tls-cert-file=/etc/kubernetes/ssl/kubernetes.pem --tls-private-key-file=/etc/kubernetes/ssl/kubernetes-key.pem --insecure-port=0 --audit-dynamic-configuration --audit-log-maxage=15 --audit-log-maxbackup=3 --audit-log-maxsize=100 --audit-log-truncate-enabled --audit-log-path=/var/log/kube-apiserver-audit.log --audit-policy-file=/etc/kubernetes/audit-policy.yaml --profiling --anonymous-auth=false --client-ca-file=/etc/kubernetes/ssl/ca.pem --requestheader-allowed-names=\\\"aggregator\\\" --requestheader-client-ca-file=/etc/kubernetes/ssl/ca.pem --requestheader-extra-headers-prefix=\\\"X-Remote-Extra-\\\" --requestheader-group-headers=X-Remote-Group --requestheader-username-headers=X-Remote-User --service-account-key-file=/etc/kubernetes/ssl/ca.pem --authorization-mode=RBAC --runtime-config=api/all=true --enable-admission-plugins=NodeRestriction --allow-privileged=true --apiserver-count=3 --event-ttl=168h --kubelet-certificate-authority=/etc/kubernetes/ssl/ca.pem --kubelet-client-certificate=/etc/kubernetes/ssl/kubernetes.pem --kubelet-client-key=/etc/kubernetes/ssl/kubernetes-key.pem --kubelet-https=true --kubelet-timeout=10s --proxy-client-cert-file=/etc/kubernetes/ssl/proxy-client.pem --proxy-client-key-file=/etc/kubernetes/ssl/proxy-client-key.pem --service-cluster-ip-range={{cluster_service_ip_range}} --service-node-port-range={{cluster_node_port_range}} --logtostderr=true --v=3 1>>/var/log/kube-apiserver.log 2>&1\"\n        ],\n        \"volumeMounts\": [\n          { \n            \"name\": \"encryption-config\",\n            \"mountPath\": \"/etc/kubernetes/encryption-config.yaml\",\n            \"readOnly\": true\n          },\n          { \n            \"name\": \"audit-policy-config\",\n            \"mountPath\": \"/etc/kubernetes/audit-policy.yaml\",\n            \"readOnly\": true\n          },\n          { \n            \"name\": \"apiserver-logfile\",\n            \"mountPath\": \"/var/log/kube-apiserver.log\",\n            \"readOnly\": false\n          },\n          { \n            \"name\": \"audit-logfile\",\n            \"mountPath\": \"/var/log/kube-apiserver-audit.log\",\n            \"readOnly\": false\n          },\n          { \n            \"name\": \"kubernetes-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/kubernetes.pem\",\n            \"readOnly\": true\n          },\n          { \n            \"name\": \"kubernetes-key-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/kubernetes-key.pem\",\n            \"readOnly\": true\n          },\n          { \n            \"name\": \"proxy-client-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/proxy-client.pem\",\n            \"readOnly\": true\n          },\n          { \n            \"name\": \"proxy-client-key-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/proxy-client-key.pem\",\n            \"readOnly\": true\n          },\n          {\n            \"name\": \"ca-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/ca.pem\",\n            \"readOnly\": true\n          }\n        ]\n      }\n    ],\n    \"volumes\":[\n      { \n        \"name\": \"encryption-config\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/config/encryption-config.yaml\"\n        }\n      },\n      { \n        \"name\": \"audit-policy-config\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/config/audit-policy.yaml\"\n        }\n      },\n      { \n        \"name\": \"apiserver-logfile\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/log/kube-apiserver.log\",\n          \"type\": \"FileOrCreate\"\n        }\n      },\n      { \n        \"name\": \"audit-logfile\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/log/kube-apiserver-audit.log\",\n          \"type\": \"FileOrCreate\"\n        }\n      },\n      { \n        \"name\": \"kubernetes-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/kubernetes.pem\"\n        }\n      },\n      { \n        \"name\": \"kubernetes-key-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/kubernetes-key.pem\"\n        }\n      },\n      { \n        \"name\": \"proxy-client-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/proxy-client.pem\"\n        }\n      },\n      { \n        \"name\": \"proxy-client-key-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/proxy-client-key.pem\"\n        }\n      },\n      { \n        \"name\": \"ca-pem\",\n          \"hostPath\": {\n            \"path\": \"{{k8s_cluster_root}}/ssl/ca.pem\"\n          }\n      }\n    ]\n  }\n}\n```','k8s,apiserver','admin','2019-12-23 15:16:19',2),(4,'kubernetes kube-controller-manager.json','# kube-controller-manager.json\n```yml\n{\n  \"apiVersion\": \"v1\",\n  \"kind\": \"Pod\",\n  \"metadata\": {\n    \"name\":\"kube-controller-manager\",\n    \"namespace\": \"kube-system\",\n    \"annotations\": {\n      \"scheduler.alpha.kubernetes.io/critical-pod\": \"\",\n      \"seccomp.security.alpha.kubernetes.io/pod\": \"docker/default\"\n    },\n    \"labels\": {\n      \"tier\": \"control-plane\",\n      \"component\": \"kube-controller-manager\",\n      \"type.pod.kubernetes.io\": \"system\"\n    }\n  },\n  \"spec\":{\n    \"hostNetwork\": true,\n    \"containers\":[\n      {\n        \"name\": \"kube-controller-manager\",\n        \"image\": \"{{kube_controller_manager_images}}\",\n        \"resources\": {\n          \"requests\": {\n            \"cpu\": \"{{kube_controller_manager_request_cpu}}\",\n            \"memory\": \"{{kube_controller_managerrequest_memory}}\"\n          },\n          \"limits\": {\n            \"cpu\": \"{{kube_controller_manager_limit_cpu}}\",\n            \"memory\": \"{{kube_controller_manager_limit_memory}}\"\n          }\n        },\n        \"livenessProbe\": {\n          \"httpGet\": {\n            \"host\": \"127.0.0.1\",\n            \"port\": 10252,\n            \"path\": \"/healthz\"\n          },\n          \"initialDelaySeconds\": 15,\n          \"timeoutSeconds\": 15\n        },\n        \"command\": [\n          \"/bin/sh\",\n          \"-c\",\n          \"exec /usr/local/bin/kube-controller-manager --profiling --allocate-node-cidrs=true --cluster-cidr=${CLUSTER_POD_CIDR} --cluster-name=kubernetes --controllers=*,bootstrapsigner,tokencleaner --kube-api-qps=1000 --kube-api-burst=2000 --leader-elect --use-service-account-credentials --concurrent-service-syncs=2 --bind-address={{ansible_host}} --address=127.0.0.1 --secure-port=10252 --tls-cert-file=/etc/kubernetes/ssl/kube-controller-manager.pem --tls-private-key-file=/etc/kubernetes/ssl/kube-controller-manager-key.pem --authentication-kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig --client-ca-file=/etc/kubernetes/ssl/ca.pem --requestheader-allowed-names=\\\"\\\" --requestheader-client-ca-file=/etc/kubernetes/ssl/ca.pem --requestheader-extra-headers-prefix=\\\"X-Remote-Extra-\\\" --requestheader-group-headers=X-Remote-Group --requestheader-username-headers=X-Remote-User --authorization-kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig --cluster-signing-cert-file=/etc/kubernetes/ssl/ca.pem --cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem --experimental-cluster-signing-duration=876000h --horizontal-pod-autoscaler-sync-period=10s --concurrent-deployment-syncs=10 --concurrent-gc-syncs=30 --node-cidr-mask-size=24 --service-cluster-ip-range={{cluster_service_ip_range}} --pod-eviction-timeout=6m --terminated-pod-gc-threshold=10000 --root-ca-file=/etc/kubernetes/certs/ca.pem --service-account-private-key-file=/etc/kubernetes/certs/ca-key.pem --kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig --v=3 1>>/var/log/kube-controller-manager.log 2>&1\"\n        ],\n        \"volumeMounts\": [\n          { \n            \"name\": \"ca-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/ca.pem\",\n            \"readOnly\": true\n          },\n          {\n            \"name\": \"ca-key-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/ca-key.pem\",\n            \"readOnly\": true\n          },\n          { \n            \"name\": \"kube-controller-manager-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/kube-controller-manager.pem\",\n            \"readOnly\": true\n          },\n          {\n            \"name\": \"kube-controller-manager-key-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/kube-controller-manager-key.pem\",\n            \"readOnly\": true\n          },\n          { \n            \"name\": \"kube-controller-manager-logfile\",\n            \"mountPath\": \"/var/log/kube-controller-manager.log\",\n            \"readOnly\": false\n          },\n          { \n            \"name\": \"kube-controller-manager-config\",\n            \"mountPath\": \"/etc/kubernetes/kube-controller-manager.kubeconfig\",\n            \"readOnly\": true\n          }\n        ]\n      }\n    ],\n    \"volumes\":[\n      { \n        \"name\": \"ca-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/ca.pem\"\n        }\n      },\n      { \n        \"name\": \"ca-key-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/ca-key.pem\"\n        }\n      },\n      { \n        \"name\": \"kube-controller-manager-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/kube-controller-manager.pem\"\n        }\n      },\n      { \n        \"name\": \"kube-controller-manager-key-pem\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/ssl/kube-controller-manager-key.pem\"\n        }\n      },\n      { \n        \"name\": \"kube-controller-manager-logfile\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/logs/kube-controller-manager.log\",\n          \"type\": \"FileOrCreate\"\n        }\n      },\n      { \n        \"name\": \"kube-controller-manager-config\",\n        \"hostPath\": {\n          \"path\": \"{{k8s_cluster_root}}/config/kube-controller-manager.kubeconfig\"\n        }\n      }\n    ]\n  }\n}\n```','k8s,kube-controller-manager','admin','2019-12-23 16:22:45',2),(5,'kubernetes kube-scheduler.json','# kube-scheduler.json\n```yml\n{\n  \"apiVersion\": \"v1\",\n  \"kind\": \"Pod\",\n  \"metadata\": {\n    \"name\":\"kube-scheduler\",\n    \"namespace\": \"kube-system\",\n    \"annotations\": {\n      \"scheduler.alpha.kubernetes.io/critical-pod\": \"\",\n      \"seccomp.security.alpha.kubernetes.io/pod\": \"docker/default\"\n    },\n    \"labels\": {\n      \"tier\": \"control-plane\",\n      \"component\": \"kube-scheduler\",\n      \"type.pod.kubernetes.io\": \"system\"\n    }\n  },\n  \"spec\":{\n    \"hostNetwork\": true,\n    \"containers\":[\n      {\n        \"name\": \"kube-scheduler\",\n        \"image\": \"{{kube_scheduler_images}}\",\n        \"resources\": {\n          \"requests\": {\n            \"cpu\": \"{{kube_scheduler_request_cpu}}\",\n            \"memory\": \"{{kube_scheduler_request_memory}}\"\n          },\n          \"limits\": {\n            \"cpu\": \"{{kube_scheduler_limit_cpu}}\",\n            \"memory\": \"{{kube_scheduler_limit_memory}}\"\n          }\n        },\n        \"livenessProbe\": {\n          \"httpGet\": {\n            \"host\": \"127.0.0.1\",\n            \"port\": 10251,\n            \"path\": \"/healthz\"\n          },\n          \"initialDelaySeconds\": 15,\n          \"timeoutSeconds\": 15\n        },\n        \"command\": [\n          \"/bin/sh\",\n          \"-c\",\n          \"exec /usr/local/bin/kube-scheduler --config=/etc/kubernetes/kube-scheduler.yaml --bind-address={{ansible_host}} --secure-port=10259 --port=0 --tls-cert-file=/etc/kubernetes/ssl/kube-scheduler.pem --tls-private-key-file=/etc/kubernetes/ssl/kube-scheduler-key.pem --authentication-kubeconfig=/etc/kubernetes/kube-scheduler.kubeconfig --client-ca-file=/etc/kubernetes/ssl/ca.pem --requestheader-allowed-names=\\\"\\\" --requestheader-client-ca-file=/etc/kubernetes/ssl/ca.pem --requestheader-extra-headers-prefix=\\\"X-Remote-Extra-\\\" --requestheader-group-headers=X-Remote-Group --requestheader-username-headers=X-Remote-User --authorization-kubeconfig=/etc/kubernetes/kube-scheduler.kubeconfig --v=3 1>>/var/log/kube-scheduler.log 2>&1\"\n        ],\n        \"volumeMounts\": [\n          {\n            \"name\": \"kube-scheduler-logfile\",\n            \"mountPath\": \"/var/log/kube-scheduler.log\",\n            \"readOnly\": false\n          },\n          {\n            \"name\": \"kube-scheduler-kubeconfig\",\n            \"mountPath\": \"/etc/kubernetes/kube-scheduler.kubeconfig\",\n            \"readOnly\": true\n          },\n          {\n            \"name\": \"kube-scheduler-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/kube-scheduler.pem\",\n            \"readOnly\": true\n          },\n          {\n            \"name\": \"kube-scheduler-key-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/kube-scheduler-key.pem\",\n            \"readOnly\": true\n          },\n          {\n            \"name\": \"ca-pem\",\n            \"mountPath\": \"/etc/kubernetes/ssl/ca.pem\",\n            \"readOnly\": true\n          },\n          {\n            \"name\": \"kube-scheduler-config\",\n            \"mountPath\": \"/etc/kubernetes/kube-scheduler.yaml\",\n            \"readOnly\": true\n          }\n        ]\n      }\n    ],\n    \"volumes\":[\n      {\n        \"name\": \"kube-scheduler-logfile\",\n        \"hostPath\": {\"path\": \"{{k8s_cluster_root}}/logs/kube-scheduler.log\"}\n      },\n      {\n        \"name\": \"kube-scheduler-kubeconfig\",\n        \"hostPath\": {\"path\": \"{{k8s_cluster_root}}/config/kube-scheduler.kubeconfig\"}\n      },\n      {\n        \"name\": \"kube-scheduler-pem\",\n        \"hostPath\": {\"path\": \"{{k8s_cluster_root}}/ssl/kube-scheduler.pem\"}\n      },\n      {\n        \"name\": \"kube-scheduler-key-pem\",\n        \"hostPath\": {\"path\": \"{{k8s_cluster_root}}/ssl/kube-scheduler-key.pem\"}\n      },\n      {\n        \"name\": \"ca-pem\",\n        \"hostPath\": {\"path\": \"{{k8s_cluster_root}}/ssl/ca.pem\"}\n      },\n      {\n        \"name\": \"kube-scheduler-config\",\n        \"hostPath\": {\"path\": \"{{k8s_cluster_root}}/config/kube-scheduler.yaml\"}\n      }\n    ]\n  }\n}\n```','k8s,kube-scheduler','admin','2019-12-23 16:54:03',2);
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `servers`
--

LOCK TABLES `servers` WRITE;
/*!40000 ALTER TABLE `servers` DISABLE KEYS */;
INSERT INTO `servers` VALUES (1,'127.0.0.1',22,'root','2af1ecec2428ae140797f9e4c1d8d1d5ca46d225ff857f2572bf879ab2d4520d7a78b88ca159792d90e33ba1da5b9710d40e012f296faaefe615da4c50b3b5452b845ea6b8969aad8797908841776e4440437da7520ee7673a3c1904e3ec36b64b136946127a6823767c006685efd0feb55c71649f86a2f315c3c4be4d51b3fe7d59cb0135da29dab83a1a8a0829af69c31bbdff6b51b15e9cf43d8e994c07a4ed924e2cd3c559827af8715ed97478af042252ca3580a0f7f096f43e92cde46371a2d480d7c4b20be6e50ae2075f2e7a9339622a73ec399e80578b6208e7eba64f558231bd1e1decf8a7d6c9f6ad71e2ebfeb73d3f87853b66b11798bc794395','test',1,'local','2019-12-23 10:26:16');
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
INSERT INTO `users` VALUES (1,'admin','admin','pbkdf2:sha256:150000$ymlosmY7$184ddd6854ef11252a8a0f5b78511773548bb5e9ccf7460360d936d4b72e8bf1',1,1,'13888888888','admin@admin.com','fd738c96a2af4b23bfef615638503346',1577121508,'2019-12-23 10:25:35','2019-12-23 10:25:43',NULL);
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

-- Dump completed on 2019-12-23 17:19:10
