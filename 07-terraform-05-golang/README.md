# Домашнее задание к занятию "7.5. Основы golang"

## Задача 1. Установите golang.
1. Воспользуйтесь инструкций с официального сайта: [https://golang.org/](https://golang.org/).
2. Так же для тестирования кода можно использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

## Решение.

![](img/Screenshot%202022-09-09%20at%2018.38.08.png)

## Задача 2. Знакомство с gotour.
У Golang есть обучающая интерактивная консоль [https://tour.golang.org/](https://tour.golang.org/). 
Рекомендуется изучить максимальное количество примеров. В консоли уже написан необходимый код, 
осталось только с ним ознакомиться и поэкспериментировать как написано в инструкции в левой части экрана.  

## Задача 3. Написание кода. 
Цель этого задания закрепить знания о базовом синтаксисе языка. Можно использовать редактор кода 
на своем компьютере, либо использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

1. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр). Можно запросить исходные данные 
у пользователя, а можно статически задать в коде.
Для взаимодействия с пользователем можно использовать функцию `Scanf`:

```go
package main

import "fmt"

func main() {
    fmt.Print("Enter a number: ")
    var input float64
    fmt.Scanf("%f", &input)

    output := input * 2

    fmt.Println(output)    
}
```
   
2. Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:
```go
x := []int{48,96,86,68,57,82,63,70,37,34,83,27,1997,9,17,}
```
3. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть `(3, 6, 9, …)`.

В виде решения ссылку на код или сам код. 

## Решение.


```go
package main

import "fmt"

func main() {
    fmt.Print("Введите количество метров: ")
    var input float64
    fmt.Scanf("%f", &input)

    output := input * 0.3048

    fmt.Println((input), " м. равняется", (output), "фт.")    
}
```

Результат:
![](img/Screenshot%202022-09-09%20at%2018.43.18.png)

2. Наименьший элемент будем искать, [используя цикл for](./src/minimum.go):

```go
package main

import "fmt"

func main() {
	x := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}
	minimum := x[0]
	for _, n := range x {
		if n < minimum {
			minimum = n
		}
	}
	fmt.Println(minimum)
}
```

Результат:
![](img/Screenshot%202022-09-09%20at%2018.44.57.png)

3. [Программа для вывода чисел от 0 до 100](./src/0to100.go), которые целочисленно делятся на 3


```go
package main

import "fmt"

func main() {
    end := 0
    for n := 0; n<100; n++ {
        end +=n
        if n % 3 ==0 && n != 0 {
        fmt.Println(n)
        }
    }
}

```
Результат:

![](img/Screenshot%202022-09-09%20at%2018.57.09.png)

