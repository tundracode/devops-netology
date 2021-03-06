
# Домашнее задание к занятию "5.1. Введение в виртуализацию. Типы и функции гипервизоров. Обзор рынка вендоров и областей применения."

## Задача 1

Опишите кратко, как вы поняли: в чем основное отличие полной (аппаратной) виртуализации, паравиртуализации и виртуализации на основе ОС.


- При аппаратной виртуализации не требуется модификация гостевой ОС;
- Для паравиртуализации требуется модификация ядра ОС;
- При виртуализации средствами ОС, гостевая ОС использует ядро хоста.


## Задача 2

Выберите один из вариантов использования организации физических серверов, в зависимости от условий использования.

Организация серверов:
- физические сервера,
- паравиртуализация,
- виртуализация уровня ОС.

Условия использования:
- Высоконагруженная база данных, чувствительная к отказу.
- Различные web-приложения.
- Windows системы для использования бухгалтерским отделом.
- Системы, выполняющие высокопроизводительные расчеты на GPU.

Опишите, почему вы выбрали к каждому целевому использованию такую организацию.

#### Высоконагруженная база данных, чувствительная к отказу

Физический сервер - Отсутствие дополнительной задержки, отсуствие дополнительной точки отказа,
         
#### Различные web-приложения
Виртуализация уровня ОС (контейнеры) - Высокая скорость разворачивание приложений. Простое маштабирование и не требовательность к ресурсам. 

#### Windows системы для использования бухгалтерским отделом
Паравиртуализация - нет критических требований к скорости доступа к аппаратной части.
        
#### Системы, выполняющие высокопроизводительные расчеты на GPU
Физические сервера - максимальная скорость доступа к GPU


 
## Задача 3

Выберите подходящую систему управления виртуализацией для предложенного сценария. Детально опишите ваш выбор.

Сценарии:

1. 100 виртуальных машин на базе Linux и Windows, общие задачи, нет особых требований. Преимущественно Windows based инфраструктура, требуется реализация программных балансировщиков нагрузки, репликации данных и автоматизированного механизма создания резервных копий.

2. Требуется наиболее производительное бесплатное open source решение для виртуализации небольшой (20-30 серверов) инфраструктуры на базе Linux и Windows виртуальных машин.
3. Необходимо бесплатное, максимально совместимое и производительное решение для виртуализации Windows инфраструктуры.
4. Необходимо рабочее окружение для тестирования программного продукта на нескольких дистрибутивах Linux.

#### 1. 
Hyper-V, vSphere поддерживают виртуальные машины с Windows и Linux, могут работать в кластере и управляться из единого центра


#### 2.
Proxmox в режиме KVM поддерживает гостевые Windows и Linux.

#### 3.
Hyper-V нативное решение Microsoft, полностью бесплатен.

#### 4.
С помощью LXD можно создавать легковесные виртуальные машины с собственным ядром.


## Задача 4

Опишите возможные проблемы и недостатки гетерогенной среды виртуализации (использования нескольких систем управления виртуализацией одновременно) и что необходимо сделать для минимизации этих рисков и проблем. Если бы у вас был выбор, то создавали бы вы гетерогенную среду или нет? Мотивируйте ваш ответ примерами.

В гетерогенной виртуальной среде могут быть следующие проблемы:
- в гетерогенной среде резко сокращаются возможности автоматического распределения вычислительных ресурсов, что увеличивает вероятность появления дефицита вычислительных ресурсов на одном из участков виртуальной среды;
- для автоматизации мониторинга зачастую используются несколько различных программных продуктов, что снижает оперативность оценки состояния вычислительных ресурсов;
- Необходима экспертиза в разных видах используемых технологиях, что увеличивает штат инженеров или расходы на техподдержку.

Для минимизации проблем соответственно лучшее решение мигрировать на одну платформу, либо стремиться к минимизации разнообразия технологий и избегать использования гипервизоров в которых меньше всего экспертизы. 