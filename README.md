Поднять сервис db_va можно командой:

`docker-compose up otusdb`

Для подключения к БД используйте команду:

`docker-compose exec otusdb mysql -u root -p12345 customers`

Для использования в клиентских приложениях можно использовать команду:

`mysql -u root -p12345 --port=3309 --protocol=tcp customers`

Были проведены эталонные тесты sysbench-ом  в режиме использования БД OLTP.
Выбраны тесты read_only_oltp и read_write_oltp из набора подготовленных тестов sysbench.
Команды для выполнения и результаты сохраненны в соответствующих файлах. 