## 使用

#### clone 到本地
```
git clone git@github.com:friendly-u/k8s-elect.git
```

#### 编译
```
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOFLAGS=-mod=vendor go build -o elect main.go

docker build -t hub.ucloudadmin.com/leesin/elect:test .
docker push hub.ucloudadmin.com/leesin/elect:test
```

#### 部署服务
保存下面yaml为deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: elect
spec:
  replicas: 3
  selector:
    matchLabels:
      app: elect
  template:
    metadata:
      labels:
        app: elect
    spec:
      containers:
      - name: elect
        image: hub.ucloudadmin.com/leesin/elect:test
        imagePullPolicy: IfNotPresent
        resources:
          requests:
            memory: 64Mi
            cpu: 100m
          limits:
            memory: 128Mi
            cpu: 200m
        command:
          - "/app/elect"
        args:
          - -lease-lock-name=elect-test
          - -lease-lock-namespace=default
          - -kubeconfig=/app/configs/kubeconfig-x1
        ports:
        - containerPort: 8000
          name: http
        env:
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        volumeMounts:
        - mountPath: /app/configs
          name: kubeconfig
      volumes:
      - configMap:
          name: kubeconfig
        name: kubeconfig
```


挂载的 kubeconfig，保存为 configmap.yaml
```yaml
apiVersion: v1
data:
  kubeconfig: |
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority: /Users/wangxiong/.minikube/ca.crt
        extensions:
        - extension:
            last-update: Mon, 02 Aug 2021 10:12:10 CST
            provider: minikube.sigs.k8s.io
            version: v1.22.0-beta.0
          name: cluster_info
        server: https://127.0.0.1:58512
      name: minikube
    contexts:
    - context:
        cluster: minikube
        extensions:
        - extension:
            last-update: Mon, 02 Aug 2021 10:12:10 CST
            provider: minikube.sigs.k8s.io
            version: v1.22.0-beta.0
        name: context_info
        namespace: default
        user: minikube
    name: minikube
    current-context: minikube
    kind: Config
    preferences: {}
    users:
    - name: minikube
    user:
        client-certificate: /Users/wangxiong/.minikube/profiles/minikube/client.crt
        client-key: /Users/wangxiong/.minikube/profiles/minikube/client.key
kind: ConfigMap
metadata:
  name: kubeconfig
```

```
k apply -f deployment.yaml configmap.yaml
```

#### 查看pod日志