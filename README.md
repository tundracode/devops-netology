# devops-netology

## Благодаря добавленному .gitignore будут проигнорированы:

- локальные каталоги `.terraform` и файлы имеющие в своем названии, либо заканчивающиесь на `.tfstate`

- файлы журнала сбоев crash.log и все файлы заканчивающиеся на `.tfvars`

- файлы переопределения `override.tf, override.tf.json` и заканчивающиеся на `_override.tf` и `_override.tf.json`

- файлы конфигураций CLI .`terraformrc` и `terraform.rc`

###### New string - fix branch