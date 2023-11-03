#  Дипломная работа по профессии «Системный администратор» - Севкин В.А.

---------
## Задача
<details>
   <summary> Открыть для подробного ознакомления </summary>
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/) и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте [инструкцию](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#get-credentials).


## Инфраструктура
Для развёртки инфраструктуры используйте Terraform и Ansible.  

Важно: используйте по-возможности **минимальные конфигурации ВМ**:2 ядра 20% Intel ice lake, 2-4Гб памяти, 10hdd, прерываемая. 

Так как прерываемая ВМ проработает не больше 24ч, после сдачи работы на проверку свяжитесь с вашим дипломным руководителем и договоритесь запустить инфраструктуру к указанному времени.


### Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

Протестируйте сайт
`curl -v <публичный IP балансера>:80` 

### Мониторинг
Создайте ВМ, разверните на ней Prometheus. На каждую ВМ из веб-серверов установите Node Exporter и [Nginx Log Exporter](https://github.com/martin-helmich/prometheus-nginxlog-exporter). Настройте Prometheus на сбор метрик с этих exporter.

Создайте ВМ, установите туда Grafana. Настройте её на взаимодействие с ранее развернутым Prometheus. Настройте дешборды с отображением метрик, минимальный набор — Utilization, Saturation, Errors для CPU, RAM, диски, сеть, http_response_count_total, http_response_size_bytes. Добавьте необходимые [tresholds](https://grafana.com/docs/grafana/latest/panels/thresholds/) на соответствующие графики.

### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

### Сеть
Разверните один VPC. Сервера web, Prometheus, Elasticsearch поместите в приватные подсети. Сервера Grafana, Kibana, application load balancer определите в публичную подсеть.

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Настройте все security groups на разрешение входящего ssh из этой security group. Эта вм будет реализовывать концепцию bastion host. Потом можно будет подключаться по ssh ко всем хостам через этот хост.

### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.
</details>

---------

# Выполнение работы

## Развертка инфраструктуры

Развертка инфраструктуры на YandexCloud происходит через Terrafirm.
   
Описание модулей Terraform:

| Название модуля | Что делает | 
|---|---|
|01-main.tf| Описываем подключение к YandexCloud|
|02-network.tf| Описываем настройки сети|
|03-hosts.tf| Описываем настройки хостов|
|04-alb.tf| Описываем подключение балансировщика|
|05-sec-group.tf| Описываем группы безопасности|
|06-snapshots.tf| Описываем резервное копирование|
|07-outputs.tf| Описываем вывод информации |
|08-ip-list.tf| Создание файла и занесение в него ифнформации|
|meta-*.yaml| Файлы с метаданными для хостов |

В результате получаем:
- Сеть Diplom с тремя подсетями Subnet в разных зонах. 
- 7 хостов: Web-1, Web-2, Elasticsearch, Grafana, Kibana, Prometheus, Bastion
- Балансировщик веб-серверов
- 5 груп безопасности
- Резервное копироване дисков
- документ со списком IP адресов для дальнейшей настройки Ansible
- на хост Bastion устанавливаются программы: Git и Ansible
  
<details>
<summary> Скриншот окна вывода Terraform Output после завершения</summary>
   
![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

</details>
<details>
<summary> Скриншот развернутой инфраструктура Terraform </summary>
   
![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

</details>

## Установка программ

Вся установка и настройка программ происходит c Bastion хоста через playbook Ansible. 

Перед запуском установки необходимо на хосте Bastion произвести: 
- первичное подключение к другим хостам через SSH, для подтверждения ssh ключа
- создать деррикторию /etc/ansible 
- создать в дерриктории /etc/ansibl файл ansible.cfg и внести в него настройки
- создать в дерриктории /etc/ansibl файл hosts и внести в него настройки хоста, сформированные 08-ip-list.tf
- в домашней дерриктории через "git clone https://github.com/SemkinVA/Ansible-dipl" скопировать плейбуки для Ansible
- перейти в каталог ~/Ansible-dipl и произвести ping на хосты командой "ansible all -m ping -v"

Если всё сделано верно и в результате все хосты пингуются, то переходим непосредственно к установке программ на хосты.

Для этого необходимо в дерриктории ~/Ansible-dipl выполнить команду "ansible-playbook install-all-progs.yaml" 

Результатом выполнения плейбука install-all-progs.yaml будет последовательная установ:
<details>
<summary> 1 - На хосты webserver1 и webserver2 устанавливается Nginx и вносится изменение в HTML файл </summary>
   
![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

</details>
<details>
<summary> 2 - На хост elasticsearch устанавливается Elasticsearch и вносятся правки в настройки </summary>
   
![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

</details>
<details>
<summary> 3 - На хосте kibana устанавливается Kibana и вносятся правки в настройки </summary>
   
![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

</details>
<details>
<summary> 4 - На хосты webserver1 и webserver2 устанавливается Filebeat и вносятся правки в настройки </summary>
   
![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

</details>
<details>
<summary> 5 - На хосте prometheus устанавливается Prometheus и вносятся правки в настройки </summary>
   
![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

</details>
<details>
<summary> 6 - На хосте grafana устанавливается Grafana и вносятся правки в настройки </summary>
   
![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

</details>
<details>
<summary> 7 - На хосты webserver1 и webserver2 устанавливается Node-exporters и вносятся правки в настройки </summary>
   
![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

</details>
<details>
<summary> 8 - На хосты webserver1 и webserver2 устанавливается Nginx Log Exporter и вносятся правки в настройки </summary>
   
![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

</details>

## Проверяем правильность настройки всех программ

### Проверяем работу сайта через баланстровщик

На хосте Bastion вводим "curl -v 158.160.24.30:80"

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

Или в любом браузере "158.160.24.30:80"

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

### Проверяем работу мониторинга

На хосте prometheus проверяем сбор метрик командой "curl http://192.168.20.15:9090/metrics"

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

На  хостах webserver1 и webserver2 проверяем работу Node-exporters и Nginx Log Exporter

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

Из любого браузера заходим на Grafana по ip: "84.150.48.37:3000" Пользователь: admin пароль: 123456

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

После входа проверяем необходимый Dashboard 

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

<details>
<summary> Производимые настройки в Grafana </summary>
Привязываем Prometheus
   
![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)
   
Импортируем Dashboard №1860 "Node Exporter Full" 

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

Отображение: Utilization

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

Отображение: Saturation

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

Отображение: Errors для CPU

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

Отображение: RAM

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

Отображение: диски 

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

Отображение: сеть

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

Отображение: http_response_count_total

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

Отображение: http_response_size_bytes

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

Настройка tresholds

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)
</details>

### Проверяем работу сбора Логов

На хосте elasticsearch проверяем работу хоста командой "192,168,20,10:9200/_cluster/health?pretty"

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

Из любого браузера заходим на Kibana по ip: "84.158.28.76:5601" 

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

Переходим в Discover и выбиваем необходимые параметры для просмотра

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)


<details>
<summary> Производимые настройки в Kibana </summary>
Переходим в менеджмент Kibana и добавляем новый индекс
   
![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)
</details>

### Проверяем работу резервного копирования дисков

В интерфейсе YandexCloud смотрим информацию по резервному копированию дисков

![название](https://github.com/SemkinVA/12.2-HW/blob/main/12-7.png)
