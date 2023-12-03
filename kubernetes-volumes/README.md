# Выполнено ДЗ № 4

 - [X] Основное ДЗ
 - [X] Задание со *

## В процессе сделано:
 
 - Хранение данных в Kubernetes: Volumes, Storages, Statefull-приложения
 1. Применил манифест для развертки minio
 ```
kubectl apply -f https://raw.githubusercontent.com/express42/otus-platform-snippets/master/Module-02/Kuberenetes-volumes/minio-statefulset.yaml
 ```
 Результат:
 ```
moonfox@moonfox-vm:~/otus/straymoonfox_platform/kubernetes-volumes$ kubectl get statefulsets
NAME    READY   AGE
minio   1/1     11m
 moonfox@moonfox-vm:~/otus/straymoonfox_platform/kubernetes-volumes$ kubectl get po
NAME      READY   STATUS    RESTARTS   AGE
minio-0   1/1     Running   0          7m9s
moonfox@moonfox-vm:~/otus/straymoonfox_platform/kubernetes-volumes$ kubectl get pvc
NAME           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-minio-0   Bound    pvc-d248f7fa-a271-453a-9698-dd04b3dce53b   10Gi       RWO            standard       7m11s
moonfox@moonfox-vm:~/otus/straymoonfox_platform/kubernetes-volumes$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                  STORAGECLASS   REASON   AGE
pvc-d248f7fa-a271-453a-9698-dd04b3dce53b   10Gi       RWO            Delete           Bound    default/data-minio-0   standard                8m9s
 ```
 2. Применил манифест для создания сервиса для minio
 ```
kubectl apply -f https://raw.githubusercontent.com/express42/otus-platform-snippets/master/Module-02/Kuberenetes-volumes/minio-headless-service.yaml
 ```
```
moonfox@moonfox-vm:~/otus/straymoonfox_platform/kubernetes-volumes$ kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP    33m
minio        ClusterIP   None         <none>        9000/TCP   5s
```
 3. Задание со *: поместить учетные данные в secrets
 Создан манифест minio-creds.yaml
 ```
 apiVersion: v1
kind: Secret
metadata:
  name: minio-creds
type: kubernetes.io/basic-auth
stringData:
  login: minio
  password: minio123

 ```
 Отредактирован манифест minio-statefulset.yaml, template.spec:
 ```
 ...
         - name: MINIO_ACCESS_KEY
          valueFrom:
            secretKeyRef:
              name: minio-creds
              key: login
        - name: MINIO_SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: minio-creds
              key: password
 ...
 ```
Применен манифест minio-creds.yaml

```
moonfox@moonfox-vm:~/otus/straymoonfox_platform/kubernetes-volumes$ kubectl get secret
NAME          TYPE                       DATA   AGE
minio-creds   kubernetes.io/basic-auth   2      5m2s
```

## Как запустить проект:
 - git pull https://github.com/otus-kuber-2023-10/straymoonfox_platform.git
 - cd kubernetes-volumes
 - kubectl apply -f minio-statefulset.yaml; kubectl apply -f minio-headless-service.yaml; kubectl apply -f minio-creds.yml

## Как проверить работоспособность:
 - kubectl get po; kubectl get svc; kubectl get pv; kubectl get pvc; kubectl get statefulsets; kubectl get secret

## PR checklist:
 - [X] Выставлен label с темой домашнего задания