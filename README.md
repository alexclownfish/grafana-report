# grafana-report

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


