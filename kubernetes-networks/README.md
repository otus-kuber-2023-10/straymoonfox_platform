# Выполнено ДЗ № 3

 - [X] Основное ДЗ
 - [X] Задание со *

## В процессе сделано:
 
 - Сетевая подсистема Kubernetes
 1. Добавил в докер образ из первого ДЗ index.html
 2. Добавил в web.yaml:
```bash
        readinessProbe:
          httpGet:
            path: /index.html
            port: 80
```
применил манифест, получил
```bash
NAME READY STATUS  RESTARTS AGE
web  0/1   Running 0        3m11s
```

 3. Добавил в web.yaml:
 ```bash
        livenessProbe:
          tcpSocket: { port: 8000 }
 ``` 
 применил манифест, отключив предварительно readinessProbe, получил в describe
 ```bash 
Liveness:     tcp-socket :8000 delay=0s timeout=1s period=10s #success=1 #failure=3
 ```
 4. Выполнил в minicube ssh :
 ```bash
 ps aux | grep my_web_server_process
 ```
 команда не имеет смысла потому, что она создает новый процесс и всегда возвращает PID работы самого grep.
 Проверять таким образом можно работу какого то элемента внутри пода, вырезая grep из вывода.  
 например:
 ```bash
 ps aux | grep nginx | grep -v grep
 ```
 5. Создал манифест web-deploy.yaml на основе web.yaml, удалил старый под 
 ```bash
 kubectl delete pod/web --grace-period=0 --force 
 ```
 применил манифест.

 6. Заменил в readinessProbe порт на 8000, replicas поднял до 3, ошибка ушла, поды поднялись.

 7. Применил манифест с различной комбинацией значений maxUnavailable,maxSurge:  
 При выставлении 0 0, возникает ошибка, данная комбинация недопустима в манифесте.  
 ```bash
 The Deployment "web" is invalid: spec.strategy.rollingUpdate.maxUnavailable: Invalid value: intstr.IntOrString{Type:1, IntVal:0, StrVal:"0%"}: may not be 0 when `maxSurge` is 0
 ```
 8. Создал манифест web-svc-cip.yaml, применил его. 

 9. Проверил результат создания сервиса:  
 ```bash
 minikube ssh
 curl http://10.111.30.208/index.html
 sudo -i
 ip addr show
 iptables --list -nv -t nat | grep 10.111.30.208
 ```
 Вывод iptables:  
 ```bash
    3   180 KUBE-SVC-6CZTMAROCN3AQODZ  tcp  --  *      *       0.0.0.0/0            10.111.30.208   /* default/web-svc-cip cluster IP */ tcp dpt:80
    3   180 KUBE-MARK-MASQ  tcp  --  *      *      !10.244.0.0/16        10.111.30.208        /* default/web-svc-cip cluster IP */ tcp dpt:80
 ```
 10. Включаю ipvs 
 ```bash
 kubectl -n kube-system edit configmaps kube-proxy
 ```
Добавляю data.config.conf:|- mode: "ipvs"  
Меняю ipvs.strictARP: False на ipvs.strictARP: true  
Удаляю под kube-proxy  
```bash
kubectl -n kube-system delete pod --selector='k8s-app=kube-proxy'
```
проверяю изменения правил внутри ноды  
```bash
iptables --list -nv -t nat
```
У цепочек 0 preference, kube-proxy настроил все по новому, но не удалил старые

Запуск kube-proxy --cleanup не помогает 
```bash
kubectl -n kube-system exec kube-proxy-<pod> kube-proxy --cleanup <pod>
```
Полностью очищаю все правила iptables  
Создаю файл внутри ноды /tmp/iptables.cleanup и применяю его iptables-restore /tmp/iptables.cleanup  

Проверяю результат: iptables --list -nv -t nat  
Все старые правила удалены, актуальные пересоздались k8s'ом  

Адрес появился на интерфейсе ip addr show kube-ipvs0:

```bash
5: kube-ipvs0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default 
    link/ether 36:b0:40:15:a5:8f brd ff:ff:ff:ff:ff:ff
    inet 10.96.0.1/32 scope global kube-ipvs0
       valid_lft forever preferred_lft forever
    inet 10.96.0.10/32 scope global kube-ipvs0
       valid_lft forever preferred_lft forever
    inet 10.101.73.141/32 scope global kube-ipvs0
       valid_lft forever preferred_lft forever
```
11. Ссылки в методичке не актуальные, воспользовался ресурсами с доки https://metallb.universe.tf/configuration/

Применяю манифест с документации: 
```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml

```
Проверяю что поды поднялись:  
```bash
moonfox@moonfox-vm:~/otus/straymoonfox_platform/kubernetes-networks$ kubectl --namespace metallb-system get all
NAME                              READY   STATUS    RESTARTS   AGE
pod/controller-786f9df989-48p2m   1/1     Running   0          2m19s
pod/speaker-nh884                 1/1     Running   0          2m19s

NAME                      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/webhook-service   ClusterIP   10.108.68.15   <none>        443/TCP   2m19s

NAME                     DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/speaker   1         1         1       1            1           kubernetes.io/os=linux   2m19s

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/controller   1/1     1            1           2m19s

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/controller-786f9df989   1         1         1       2m19s
```

12. Настраиваю балансировщик с помощью ConfigMap metallb-config.yaml и применяю его  
```bash
moonfox@moonfox-vm:~/otus/straymoonfox_platform/kubernetes-networks$ kubectl apply -f metallb-config.yaml 
configmap/config created
```
Создаю манифест LoadBalancer и применяю его  web-svc-lb.yaml  
```bash
moonfox@moonfox-vm:~/otus/straymoonfox_platform/kubernetes-networks$ kubectl get svc
NAME          TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)        AGE
kubernetes    ClusterIP      10.96.0.1        <none>         443/TCP        54m
web-svc-cip   ClusterIP      10.96.129.170    <none>         80/TCP         54m
web-svc-lb    LoadBalancer   10.110.250.137   172.17.255.1   80:31351/TCP   44m

```

Теперь можно обращаться по нему curl-ом и каждый раз попадать на другой под

```bash
docker@minikube:~$ curl http://172.17.255.1
<html>
<head/>
<body>
<!-- IMAGE BEGINS HERE -->
```

- Задание со звездочкой: DNS через MetalLB
 1. создаем манифест сервиса, который открывает доступ к CoreDNS снаружи кластера coredns/dns-svc-metallb.yml
 
для проверки нужно с ноды кластера выполнить: nslookup coredns-svc-tcp.kube-system.svc.cluster.local 172.17.255.10
```bash
moonfox@moonfox-vm:~/otus/straymoonfox_platform/kubernetes-networks$ minikube ssh
docker@minikube:~$ nslookup coredns-svc-tcp.kube-system.svc.cluster.local 172.17.255.10
Server:		172.17.255.10
Address:	172.17.255.10#53

Name:	coredns-svc-tcp.kube-system.svc.cluster.local
Address: 10.106.133.179
```

2. Применяю манифест ingress-nginx: k
```bash
ubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/deploy.yaml
```  
создаем и деплоим nginx-lb.yaml: 
```
moonfox@moonfox-vm:~/otus/straymoonfox_platform/kubernetes-networks$ kubectl get svc --all-namespaces
NAMESPACE        NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
default          kubernetes                           ClusterIP      10.96.0.1        <none>          443/TCP                      81m
default          web-svc-cip                          ClusterIP      10.96.129.170    <none>          80/TCP                       81m
default          web-svc-lb                           LoadBalancer   10.110.250.137   172.17.255.1    80:31351/TCP                 72m
ingress-nginx    ingress-nginx                        LoadBalancer   10.98.78.151     172.17.255.2    80:30962/TCP,443:32264/TCP   17s
ingress-nginx    ingress-nginx-controller             NodePort       10.107.225.122   <none>          80:31613/TCP,443:32466/TCP   14m
ingress-nginx    ingress-nginx-controller-admission   ClusterIP      10.110.146.16    <none>          443/TCP                      14m
kube-system      coredns-svc-tcp                      LoadBalancer   10.106.133.179   172.17.255.10   53:31767/TCP                 22m
kube-system      coredns-svc-udp                      LoadBalancer   10.96.190.143    172.17.255.10   53:31765/UDP                 22m
kube-system      kube-dns                             ClusterIP      10.96.0.10       <none>          53/UDP,53/TCP,9153/TCP       81m
metallb-system   webhook-service                      ClusterIP      10.108.68.15     <none>          443/TCP                      79m

```

3. подключение приложения web к ingress. создаем headless-сервис web-svc-headless.yaml  
4. создаем ingress-прокси, создав манифест с ресурсом ingress web-ingress.yaml  
5. теперь можно обращаться к странице поду по адресу: http://172.17.255.2/web/index.html  
6. теперь балансировка выполняется посредством nginx, а не IPVS  


## Как запустить проект:
 - docker pull straymoonfox/hmwk3:v2
 - Применить манифесты

## Как проверить работоспособность:
 - Все проверки описаны в ходе работы

## PR checklist:
 - [X] Выставлен label с темой домашнего задания