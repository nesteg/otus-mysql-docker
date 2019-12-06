Поднять сервис db_va можно командой:

`docker-compose up otusdb`

Для подключения к БД используйте команду:

`docker-compose exec otusdb mysql -u root -p12345 customers`

Для использования в клиентских приложениях можно использовать команду:

`mysql -u root -p12345 --port=3309 --protocol=tcp customers`