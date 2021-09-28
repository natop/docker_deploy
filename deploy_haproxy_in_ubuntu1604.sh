cat <<EOF | sudo tee /etc/apt/sources.list
deb http://mirrors.aliyun.com/ubuntu/ xenial main
deb-src http://mirrors.aliyun.com/ubuntu/ xenial main

deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main

deb http://mirrors.aliyun.com/ubuntu/ xenial universe
deb-src http://mirrors.aliyun.com/ubuntu/ xenial universe
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates universe
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates universe

deb http://mirrors.aliyun.com/ubuntu/ xenial-security main
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main
deb http://mirrors.aliyun.com/ubuntu/ xenial-security universe
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security universe
EOF

sudo apt install -y haproxy

cat << EOF | sudo tee /etc/haproxy/haproxy.cfg
frontend kubernetes-frontend
        bind 10.10.30.10:6443
        mode tcp
        option tcplog
        default_backend kubernetes-backend

backend kubernetes-backend
        mode tcp
        option tcp-check
        balance roundrobin
        server k8s-m1 10.10.30.11:6443 check fall 3 rise 2
        server k8s-m2 10.10.30.12:6443 check fall 3 rise 2