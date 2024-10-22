# REST API для подписания XML с использованием пакета Крипто Про для python

Сам пакет https://docs.cryptopro.ru/cades/pycades  
Тестовый УЦ https://www.cryptopro.ru/certsrv/

## Развертывание в docker

1. Получаем из гита исходники  
`git clone https://github.com/npoluyaktov/pysig_service.git`  
`cd pysig_service`
2. Собираем образ  
`sudo docker build --build-arg SIG_PIN=1234567890 -t pysig_service .`  
в SIG_PIN указываем пин-код контейнера, certnew.cer заменяем на корневой сертификат нужного УЦ, папку 49503a70.000 заменяем на нужный контейнер
3. Запускаем образ в контейнере  
`sudo docker run -d -p 7080:80 --name pysig_service pysig_service`

## Работа с API

