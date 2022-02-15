# grafana-report
## 先上效果
![image](https://user-images.githubusercontent.com/63449830/154011692-024fefee-4c2f-49bb-ba83-f3c18d3bc724.png)
![1644909636(1)](https://user-images.githubusercontent.com/63449830/154012095-ccfa9645-404c-43ff-91ec-609109f81ea2.png)
![image](https://user-images.githubusercontent.com/63449830/154012175-eae58c0e-0dbd-426e-bca1-a3ca9f515545.png)

## grafana-report编译部署 
grafana本来不支持中文，改源码后支持，这里有大佬改好的现成的代码就可以拿来直接用了
```
切换目录到$GOPATH/src/
git clone https://github.com/love01211/grafana-reporter.git
编译生成二进制文件在$GOPATH/bin/
go install -v grafana-reporter/cmd/grafana-reporter
```
可直接grafana-reporter --help ，查看帮助并二进制启动。
也可自制镜像或者docker pull alexcld/grafana-report:2.0.2 使用我的

### grafana-deployment.yaml
```
apiVersion: apps/v1
kind: Deployment 
metadata:
  name: grafana
  namespace: ops
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:8.3.3
        env:
        - name: GF_RENDERING_SERVER_URL               ## grafana-image-renderer插件地址，
          value: "http://10.1.230.133:8081/render"
        - name: GF_RENDERING_CALLBACK_URL             ## grafana地址
          value: "http://172.22.254.57:30030"
        - name: GF_LOG_FILTERS
          value: "rendering:debug"
        ports:
          - containerPort: 3000
            protocol: TCP
        resources:
          limits:
            cpu: 100m            
            memory: 256Mi          
          requests:
            cpu: 100m            
            memory: 256Mi
        volumeMounts:
          - name: grafana-data
            mountPath: /var/lib/grafana
            subPath: grafana
          - mountPath: /etc/localtime
            name: timezone
          #- name: grafana-config
          #  mountPath: /etc/grafana/
      securityContext:
        fsGroup: 472
        runAsUser: 472
      volumes:
      #- name: grafana-config
      #  configMap: 
      #    name: grafana-config
      - name: grafana-data
        persistentVolumeClaim:
          claimName: grafana
      - name: timezone
        hostPath:
          path: /usr/share/zoneinfo/Asia/Shanghai 
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: grafana 
  namespace: ops
spec:
  storageClassName: "nfs-storage"
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: ops
spec:
  type: NodePort
  ports:
  - port : 80
    targetPort: 3000
    nodePort: 30030
  selector:
    app: grafana
```
### grafana-report.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: ops
  labels:
    app: grafana-report
  name: grafana-report
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana-report
  template:
    metadata:
      labels:
        app: grafana-report
    spec:
      containers:
      - image: 'alexcld/grafana-report:2.0.2'           # grafana-report原本不支持中文dashboard,修改源码后并打成镜像已经支持中文
        name: grafana-report
        ports: 
        - containerPort: 8686
        env:
          - name: TZ
            value: Asia/Shanghai
        command: ["/grafana-reporter","-ip","172.22.254.57:30030"]    # -ip 指定grafana地址
      - image: 'grafana/grafana-image-renderer:latest'   # grafana-image-renderer插件用于将grafana模板转化为图片，我通过grafana-cli安装过很多次，启动都报错需要重新编译什么的，所以这里就直接通过镜像引入了，如果你有好的方法也可以留言给我 感谢
        name: grafana-image-renderer
        ports: 
        - containerPort: 8081
        env:
          - name: TZ
            value: Asia/Shanghai
---
kind: Service
apiVersion: v1
metadata:
  name: grafana-report
  namespace: ops
  labels:
    app: grafana-report
spec:
  type: NodePort
  ports:
    - name: grafana-report
      protocol: TCP
      port: 8686
      targetPort: 8686
      nodePort: 30868
    - name: grafana-image-renderer
      protocol: TCP
      port: 8081
      targetPort: 8081
      nodePort: 30808
  selector:
    app: grafana-report
```
## grafana 操作

### 创建API TOKEN

![image](https://user-images.githubusercontent.com/63449830/154009141-a41dac3c-fa5c-48ca-ba32-ad7c29799d67.png)
![image](https://user-images.githubusercontent.com/63449830/154009197-5e826b61-fe52-4587-8b88-523ee0ccd504.png)
![image](https://user-images.githubusercontent.com/63449830/154009401-ab47fa7a-a8f7-4fda-a4f8-a7ddcfc83c0c.png)

### 配置url
#### 找到dashboard设置

![image](https://user-images.githubusercontent.com/63449830/154008657-e885332f-a510-480e-82c0-d55aa3177d77.png)

#### 配置url注意事项
http://172.22.254.57:30868/api/v5/report/viOR-qvnkdasd?apitoken=eyJrIjoiNjRZQjJlT2pKM1h2QVZLbTZWQ0pzMjFJSzdjSVFQUkYiLCJuIjoiZ3JhZmFuYS1yZXBvcnQiLCJpZCI6MX0=

* http://172.22.254.57:30868 : grafana-report地址
* /api/v5/report/ ：grafana-report接口路径
* viOR-qvnkdasd ：dashboard id
* ?apitoken=eyJrIjoiNjRZQjJlT2pKM1h2QVZLbTZWQ0pzMjFJSzdjSVFQUkYiLCJuIjoiZ3JhZmFuYS1yZXBvcnQiLCJpZCI6MX0= ：上边创建的API KEYS 用于访问grafana


还有一个地方就是我们后续会通过wget下载pdf，这样就需要一个时间范围
我一般是先在dashboard上选择好时间后点击 新加的link，然后打开的页面token后就有一串是时间范围直接拷贝过来到 定时任务的shell脚本

![image](https://user-images.githubusercontent.com/63449830/154010841-56363196-e6d1-43c9-9f5e-6d6fd5f9bd03.png)
![image](https://user-images.githubusercontent.com/63449830/154010936-bcc67f50-25e6-4dd1-b4c5-d436b13bd57d.png)



#### 找到link，并添加配置

![image](https://user-images.githubusercontent.com/63449830/154008791-77aadbf8-69cc-44a2-88be-92cc9d05d73f.png)
![image](https://user-images.githubusercontent.com/63449830/154010129-2ca46975-d3c5-432e-9403-75485e3703b2.png)

![image](https://user-images.githubusercontent.com/63449830/154008958-6940b093-9f5f-4357-a497-0577108f29fc.png)

## shell for crontab

配置好邮箱之后，通过shell脚本每天早上八点发送昨日grafana日报到领导邮箱。（领导一到公司就能看到，美滋滋）
```
#/bin/bash
#auuthor:alex
#shell for creating grafana dashboard report
filepath=/opt/grafana/report/
date=$(date +%Y-%m-%d-%H:%M)

# dashboard report name
filename_yunwei_ziyuan=运维资源全览-centernode-${date}.pdf

# download grafana dashboard report
wget -q -O ${filepath}${filename_yunwei_ziyuan} "http://172.22.254.57:30868/api/v5/report/viOR-qvnkdasd?apitoken=eyJrIjoiNjRZQjJlT2pKM1h2QVZLbTZWQ0pzMjFJSzdjSVFQUkYiLCJuIjoiZ3JhZmFuYS1yZXBvcnQiLCJpZCI6MX0=&from=now-24h&to=now&var-origin_prometheus=&var-Node=All&var-NameSpace=All&var-Container=All&var-Pod=All"

sleep 30s

# send email
mail -i \
-a ${filepath}${filename_yunwei_ziyuan} \
-s "Grafana监控日报"-`date +%Y-%m-%d-%H:%M` \
-c "21178857@qq.com" ywz0207@163.com < /opt/grafana/logs/send_mail.log 
```
