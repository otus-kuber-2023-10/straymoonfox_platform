# Выполнено ДЗ № 1

 - [X] Основное ДЗ
 - [X] Задание со *
 - [X] Задание с **

## В процессе сделано:

 - Kubernetes controllers.ReplicaSet, Deployment, DaemonSet

1. Создан докер img для frontend(v0.0.2) и paymentservice(v0.0.1 и v0.0.2)
2. Залиты образы на докерхаб
3. Был применен манифест frontend-freplicaset для frontend
4. В манифесте была ошибка, не было раздела selector, о чем была соотвествующая ошибка в describe rs, поправил манифест, запустил 3 реплики
5. Изменил образ приложения в манифесте, применил. вопрос в ДЗ - "Кажется, ничего не произошло". Потому что replicaset следит только за количеством запущенных подов, а не изменений в них.
6. Создал манифесты для replicaset и deployments микросервиса paymentService. При смене версии образа в манифесте deployments и его применении - добавляется новый replicaset и запускает новые поды
7. Cделал откат версии deployments (kubectl rollout undo deployment paymentservice --to-revision=1)
8. Сделал задание со звездочкой (2 манифеста):
- Аналог blue-green: развертывание трех новых подов, затем удаление трех старых
- Reverse Rolling Update: удаление одного старого пода, затем созданиие нового
9. Cделал манифест deployment для frontend и добавил в него предоставленные Probe's 
10. изучил причину нахождения пода в состоянии 0/1 Running - readinessProbe не прошла. поправил манифест:
- при обновлении, если readinessProbe первого пода из deployments не прошла - то deployments не будет пытаться обновлять дальше
10. Запустил DaemonSet для node-exporter:
- пробросил порты с пода (/bin/bash ./nodeexp-proxy.sh)
проверил метрики ноды (curl http://127.0.0.1:9100/metrics)
11. Нашел способ модернизировать DaemonSet таким образом, чтобы он запускался в том числе и на мастер нодах нодах kubernetes:
Taints по умолчанию запрещает разворачивать разворачивать поды на control-plane нодах, если внести в spec.tolerations operator: Exists, поды будут развернуты на всех нодах.
```bash
spec:
...
      tolerations:
      - operator: Exists
```

## Как запустить проект:
 - docker pull straymoonfox/frontend:v0.0.2
 - docker pull straymoonfox/paymentservice:v0.0.1
 - docker pull straymoonfox/paymentservice:v0.0.2
 - kubectl apply -f frontend-replicaset.yaml
 - kubectl apply -f paymentservice-replicaset.yaml
 - kubectl apply -f paymentservice-deployment.yaml
 - kubectl apply -f frontend-deployment.yaml
 - kubectl apply -f paymentservice-deployment-bg.yaml
 - kubectl apply -f paymentservice-deployment-reverse.yaml
 - kubectl apply -f node-exporter-daemonset.yaml
 - /bin/bash ./nodeexp-proxy.sh

## Как проверить работоспособность:
 - После применения манифеста frontend-replicaset.yaml
 1. kubectl get pods -l app=frontend -w
 2. Наблюдать за масштабированием числа подов

 - После применения манифеста paymentservice-replicaset.yaml убедиться что все поды в состоянии Ready 
   - kubectl get pods -l app=paymentservice

 - После применения манифеста paymentservice-deployment.yaml убедиться что все поды в состоянии Ready
   - Заменить версию образа между 0.0.1<->0.0.2
   - kubectl apply -f paymentservice-deployment.yaml | kubectl get pods -l app=paymentservice -w
   - Наблюдать что просиходит rolling-update предусмотренный по умолчанию

 - После применения манифеста paymentservice-deployment-bg.yaml убедиться что все поды в состоянии Ready
   - Заменить версию образа между 0.0.1<->0.0.2
   - kubectl apply -f paymentservice-deployment-bg.yaml | kubectl get pods -l app=paymentservice -w
   - Наблюдать что просиходит Аналог blue-green update

 - После применения манифеста paymentservice-deployment-reverse.yaml убедиться что все поды в состоянии Ready
   - Заменить версию образа между 0.0.1<->0.0.2
   - kubectl apply -f paymentservice-deployment-bg.yaml | kubectl get pods -l app=paymentservice -w
   - Наблюдать что просиходит Reverse Rolling Update
   
 - После применения манифеста node-exporter-daemonset.yaml
  - kubectl get po -n monitoring
  - /bin/bash ./nodeexp-proxy.sh
  - curl http://127.0.0.1:9100/metrics
  - Убедиться что число подов node-exporter в namespace monitoring соответствует количеству нод : control-plane's+worker's

## PR checklist:
 - [X] Выставлен label с темой домашнего задания