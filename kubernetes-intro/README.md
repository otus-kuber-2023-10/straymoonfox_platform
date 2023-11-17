# Выполнено ДЗ № 1

 - [X] Основное ДЗ
 - [X] Задание со *

## В процессе сделано:
 - Подготовка к выполнению ДЗ

 1. добавил в репозиторий файлы .github/auto_assign.yml .github/labeler.yml .github/workflows/auto-assign.yml .github/workflows/labeler.yml .github/workflows/run-tests.yml  
 2. дождался автопроверки, сделал merge-request  

 - Настройка локального окружения. Запуск первого контейнера. Работа с kubectl
 1. установил kubectl  
 2. установил и запустил minikube  
 minikube start --driver=docker  

 3. Удалил все поды
 ```bash
   kubectl delete pod --all -n kube-system  
 ``` 
 core-dns - восстанавливается т.к. имеет Replica Set описанный в Deployment core-dns в неймспейсе kube-system 
 ```bash 
 Controlled By:  ReplicaSet/coredns  
 ```

 kube-apiserver,kube-controller,kube-scheduler,kube-proxy,etcd-minikube - являются компонентами-константами control-plane, описаны статическими подами в /etc/kubernetes/manifests  
 ```bash
 Controlled By:  Node/minikube  
 ```
 4. подключил дашборд для kubernetes: https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

 5. создал Dockerfile и образ из него. выбрал rocky8 с установленным на него nginx 
 
 6. добавил образ в dockerhub  

 7. написал манифест пода web-pod.yaml и применил его 

 8. с помощью Dockerfile приложения frontend был создан образ frontend и добавлен в dockerhub

 7. написал манифест пода frontend-pod.yaml и применил его: Получил ошибку отсутствия ENV  

 8. Написал манифест пода frontend-pod.yaml, необходимые для запуска переменные посмотрел в frontend/main.go, заполнил ENV и применил его  

## Как запустить проект:
 - docker pull straymoonfox/hmwk1:v1  
 - docker pull straymoonfox/frontend:latest  
 - kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
 - kubectl apply -f web-pod.yaml  
 - kubectl apply -f frontend-pod.yaml  
 - kubectl delete pod frontend  
 - kubectl apply -f frontend-pod-healthy.yaml  

## Как проверить работоспособность:
 - После применения деплоймента Dashboard
 1. kubectl proxy
 2. Зайти на http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

 - После запуска пода web-pod.yaml Перейти по ссылке http://127.0.0.1:8000/homework.html и http://127.0.0.1:8000  

 - После запуска пода frontend-pod.yaml убедиться что под поднялся с ошибкой отсутствия ENV: kubectl logs frontend  

 - После запуска пода frontend-pod-healthy.yaml убедиться что под поднялся без ошибок:
  1. kubectl get po  
  2. kubectl describe po frontend  

## PR checklist:
 - [X] Выставлен label с темой домашнего задания