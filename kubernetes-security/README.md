# Выполнено ДЗ № 5

 - [X] Основное ДЗ

## В процессе сделано:
 
 - Безопасность и управление доступом
 1. Создал 2 манифеста в task01: 01_bob.yaml 02_dave.yaml
 bob - с правами администратора
 dave - без прав
 Применил манифесты:
 ```
 moonfox@moonfox-vm:~/otus/straymoonfox_platform/kubernetes-security/task01$ kubectl get sa
NAME      SECRETS   AGE
bob       0         21s
dave      0         6s
default   0         123m
 ```
 2. Создал 3 манифеста в task02: 01_ns_prometheus.yaml 02_carol.yaml 03_rb.yaml
 Применил манифесты:
 ```
 moonfox@moonfox-vm:~/otus/straymoonfox_platform/kubernetes-security/task02$ kubectl get ns prometheus
NAME         STATUS   AGE
prometheus   Active   22s
moonfox@moonfox-vm:~/otus/straymoonfox_platform/kubernetes-security/task02$ kubectl get sa -n prometheus
NAME      SECRETS   AGE
carol     0         28s
default   0         31s
moonfox@moonfox-vm:~/otus/straymoonfox_platform/kubernetes-security/task02$ kubectl get clusterrole.rbac.authorization.k8s.io -n prometheus
...
viewer                                                                 2023-12-03T17:45:03Z
 ```
 3. Создал 3 манифеста в task03: 01_ns_dev.yaml  02_sa_jane.yaml  03_sa_ken.yaml
 Применил манифесты:
 ```
 moonfox@moonfox-vm:~/otus/straymoonfox_platform/kubernetes-security/task03$ kubectl get sa -n dev
NAME      SECRETS   AGE
default   0         33s
jane      0         30s
ken       0         26s
moonfox@moonfox-vm:~/otus/straymoonfox_platform/kubernetes-security/task03$ kubectl get RoleBinding -n dev
NAME         ROLE                        AGE
jane-admin   ClusterRole/cluster-admin   98s
ken-view     ClusterRole/view            94s
 ```

## Как запустить проект:
 - cd task01; kubectl apply -f 01_bob.yaml; kubectl apply -f 02_dave.yaml
 - cd task02; kubectl apply -f 01_ns_prometheus.yaml kubectl apply -f 02_carol.yaml; kubectl apply -f 03_rb.yaml
 - cd task03; kubectl apply 01_ns_dev.yaml; kubectl apply 02_sa_jane.yaml; kubectl apply  03_sa_ken.yaml

## Как проверить работоспособность:
 - kubectl get sa; kubectl get ns prometheus; kubectl get sa -n prometheus; kubectl get clusterrole.rbac.authorization.k8s.io -n prometheus; kubectl get sa -n dev; kubectl get RoleBinding -n dev

## PR checklist:
 - [X] Выставлен label с темой домашнего задания