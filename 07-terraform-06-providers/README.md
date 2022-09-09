# Домашнее задание к занятию "7.6. Написание собственных провайдеров для Terraform."

---
## Задача 1. 
Давайте потренируемся читать исходный код AWS провайдера, который можно склонировать от сюда: 
[https://github.com/hashicorp/terraform-provider-aws.git](https://github.com/hashicorp/terraform-provider-aws.git).
Просто найдите нужные ресурсы в исходном коде и ответы на вопросы станут понятны.  


1. Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на 
гитхабе.   

* `resource` - https://github.com/hashicorp/terraform-provider-aws/blob/8e4d8a3f3f781b83f96217c2275f541c893fec5a/aws/provider.go#L411 
	
	
- `data_source` - https://github.com/hashicorp/terraform-provider-aws/blob/8e4d8a3f3f781b83f96217c2275f541c893fec5a/aws/provider.go#L169


2. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`. 
    * С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.

	    - ConflictsWith: []string{"name_prefix"}
	
            https://github.com/hashicorp/terraform-provider-aws/blob/8e4d8a3f3f781b83f96217c2275f541c893fec5a/aws/resource_aws_sqs_queue.go#L56
 

    * Какая максимальная длина имени? 

        -  Длина строки не более 80  символов:
         errors = append(errors, fmt.Errorf("%q cannot be longer than 80 characters", k))
         https://github.com/hashicorp/terraform-provider-aws/blob/8e4d8a3f3f781b83f96217c2275f541c893fec5a/aws/validators.go#L1038
		 

    * Какому регулярному выражению должно подчиняться имя? 
    
        - Регулярное выражение : `^[0-9A-Za-z-_]+(\.fifo)?$` - может содержать только буквы и символы +".fofo" в конце
	 
 	        есть еще 2 доп условия ниже по коду : 
		 
	        NonFifo = `^[0-9A-Za-z-_]+$` - может содержать только буквы, цифры, подчеркиванием, 
		
	        Fifo = `^[0-9A-Za-z-_.]+$` - так же может содержать только буквы, цифры, подчеркивание, а так же точку, 
			
	        `^[^a-zA-Z0-9-_]` -  и при этом начинаться только с букв, цифр, подчеркивания,
			    
            https://github.com/hashicorp/terraform-provider-aws/blob/8e4d8a3f3f781b83f96217c2275f541c893fec5a/aws/validators.go#L1041	
