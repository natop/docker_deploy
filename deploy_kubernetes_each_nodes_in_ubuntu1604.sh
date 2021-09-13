#!/bin/sh
cat <<EOF | sudo tee /etc/hosts
10.10.30.10 k8s-m1
10.10.30.11 k8s-m2
10.10.30.12 k8s-w1
10.10.30.13 k8s-w2
EOF

curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add - 
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install -y kubeadm=1.20.0-00 kubectl=1.20.0-00 kubelet=1.20.0-00
sudo apt-mark hold kubelet kubeadm kubectl

sudo swapoff -a
sudo sed -i '/swap/s/^/#/' /etc/fstab

sudo kubeadm init --apiserver-advertise-address `ip addr show ens160 | grep 'inet ' | cut -d' ' -f6 | cut -d / -f1` --image-repository registry.aliyuncs.com/google_containers --pod-network-cidr 10.244.0.0/16 --kubernetes-version v1.20.0
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f kube-flannel.yml