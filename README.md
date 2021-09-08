## 使用

#### clone 到本地
```
git clone git@github.com:friendly-u/k8s-elect.git
```

#### 编译
```
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOFLAGS=-mod=vendor go build -o elect main.go

docker build -t docker.io/xxx/elect:test .
docker push docker.io/xxx/elect:test
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
        image: docker.io/xxx/elect:test
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
          - -kubeconfig=/app/configs/kubeconfig
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
   xxxxx
   xxxx
   xxx
   xx
   x
kind: ConfigMap
metadata:
  name: kubeconfig
```

```
k apply -f deployment.yaml configmap.yaml
```

#### 查看pod日志
