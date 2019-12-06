-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema customers
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `customers` ;

-- -----------------------------------------------------
-- Schema customers
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `customers` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
USE `customers` ;

-- -----------------------------------------------------
-- Table `customers`.`streets`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`streets` (
  `street_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Перв. ключ для сущ. streets.Уулицы может быть несколько частей (substreets).Каждая часть имеет свой почтовый индекс.',
  `street` VARCHAR(100) CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_unicode_ci' NULL DEFAULT NULL COMMENT 'Название улицы.',
  PRIMARY KEY (`street_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `customers`.`countrys`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`countrys` (
  `country_id` SMALLINT(3) UNSIGNED ZEROFILL NOT NULL AUTO_INCREMENT COMMENT 'Ключ  страны.',
  `symbols` VARCHAR(2) NOT NULL COMMENT 'название страны (2 символа).',
  `full_name` VARCHAR(45) NULL,
  PRIMARY KEY (`country_id`),
  UNIQUE INDEX `FullName_UNIQUE` (`symbols` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `customers`.`regions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`regions` (
  `region_id` SMALLINT(5) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Ключ региона.',
  `region` VARCHAR(24) NULL DEFAULT NULL COMMENT 'название региона',
  `country_id` SMALLINT(3) UNSIGNED ZEROFILL NOT NULL COMMENT 'Внешний ключ на Id страны в которой он находится.',
  PRIMARY KEY (`region_id`),
  INDEX `fkcountry_idx` (`country_id` ASC) VISIBLE,
  CONSTRAINT `fkcountry`
    FOREIGN KEY (`country_id`)
    REFERENCES `customers`.`countrys` (`country_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `customers`.`postalcodes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`postalcodes` (
  `postalcode_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Ключ почтового индекса.',
  `postalcode` VARCHAR(24) NULL DEFAULT NULL COMMENT 'Собственно сам индекс.',
  `region_id` SMALLINT(5) UNSIGNED NOT NULL COMMENT 'Внеш. ключ на на ключ региона.',
  PRIMARY KEY (`postalcode_id`),
  INDEX `fkregion_idx` (`region_id` ASC) VISIBLE,
  CONSTRAINT `fkregion`
    FOREIGN KEY (`region_id`)
    REFERENCES `customers`.`regions` (`country_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `customers`.`towns`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`towns` (
  `town_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Перв. ключ для сущ. towns.В нас. пункте может быть несколько частей (subtowns).Каждая часть имеет свой почтовый индекс.Или город (тогда это поселок) относится почтовому индексу как и какиу-то другие нас.пункты.',
  `town` VARCHAR(24) NULL COMMENT 'название нас пункта.',
  PRIMARY KEY (`town_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `customers`.`subtowns`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`subtowns` (
  `subtown_id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Ключ для субсущности часть города.Эта часть города привязанна к уникальному почтовому индексу.',
  `towns_id` INT UNSIGNED NOT NULL COMMENT 'внешний ключ на перв. ключ сущности towns. ',
  `post_id` INT UNSIGNED NOT NULL COMMENT 'внешний ключ на первичный ключ таблицы postalcode.',
  INDEX `fk_towns_postalcodes_postalcodes1_idx` (`post_id` ASC) VISIBLE,
  INDEX `fk_towns_postalcodes_towns1_idx` (`towns_id` ASC) VISIBLE,
  PRIMARY KEY (`subtown_id`),
  CONSTRAINT `fk_towns_postalcodes_postalcodes1`
    FOREIGN KEY (`post_id`)
    REFERENCES `customers`.`postalcodes` (`postalcode_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_towns_postalcodes_towns1`
    FOREIGN KEY (`towns_id`)
    REFERENCES `customers`.`towns` (`town_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `customers`.`substreets`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`substreets` (
  `substreet_id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Ключ для субсущности часть улицы.Эта часть улицы привязанна к уникальному почтовому индексу через субсущность город и улицу.',
  `street_id` INT UNSIGNED NOT NULL COMMENT 'внешний ключ на перв. ключ streets.',
  `subtown_id` INT UNSIGNED NOT NULL COMMENT 'внешний ключ на перв. ключ сущ. subtowns.',
  INDEX `fk_sreets_postalcodes_streets1_idx` (`street_id` ASC) VISIBLE,
  PRIMARY KEY (`substreet_id`),
  INDEX `fk_ui_idx` (`subtown_id` ASC) VISIBLE,
  CONSTRAINT `fk_sreets_postalcodes_streets1`
    FOREIGN KEY (`street_id`)
    REFERENCES `customers`.`streets` (`street_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ui`
    FOREIGN KEY (`subtown_id`)
    REFERENCES `customers`.`subtowns` (`subtown_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `customers`.`addresses`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`addresses` (
  `address_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Ключ адреса.',
  `house` VARCHAR(9) NULL DEFAULT NULL COMMENT 'Литера номер дома.Может быть сложной.Поэтому строка.',
  `substreet_id` INT UNSIGNED NOT NULL COMMENT 'Внеш. ключ на часть улицы и соответсвенно почтового индекса к которому относиться дом.',
  PRIMARY KEY (`address_id`),
  INDEX `fksubstreet_idx` (`substreet_id` ASC) VISIBLE,
  CONSTRAINT `fksubstreet`
    FOREIGN KEY (`substreet_id`)
    REFERENCES `customers`.`substreets` (`substreet_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `customers`.`titles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`titles` (
  `title_id` TINYINT(3) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Ключ обращения к персоне.',
  `title` VARCHAR(7) NULL DEFAULT NULL COMMENT 'Обращение.',
  PRIMARY KEY (`title_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `customers`.`languages`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`languages` (
  `language_id` TINYINT(3) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Ключ разговорного языка.',
  `language` VARCHAR(2) NULL DEFAULT NULL COMMENT 'Разговорный язык (2 символа).',
  PRIMARY KEY (`language_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `customers`.`customs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`customs` (
  `custom_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Ключ клиента.Суррогатный потому что по фамилии и имени и т.д. могут быть совпадения.',
  `gender` TINYINT(3) UNSIGNED NOT NULL COMMENT 'Номер пола.',
  `title_id` TINYINT(3) UNSIGNED NOT NULL COMMENT 'Вн. ключ на сущность titles.',
  `birthday` DATE NULL DEFAULT NULL COMMENT 'день рождения.',
  `marital_status` BIT(1) NULL COMMENT 'Семейное положение:0 - Нет половины,1- есть половина.',
  `language_id` TINYINT(3) UNSIGNED NOT NULL COMMENT 'Вн. ключ на разговорный язык.',
  `first_name` VARCHAR(100) NULL COMMENT 'Имя',
  `last_name` VARCHAR(100) NULL COMMENT 'Фамилия',
  PRIMARY KEY (`custom_id`),
  INDEX `fktitle_idx` (`title_id` ASC) VISIBLE,
  INDEX `fk_customs_languages1_idx` (`language_id` ASC) VISIBLE,
  CONSTRAINT `fktitle`
    FOREIGN KEY (`title_id`)
    REFERENCES `customers`.`titles` (`title_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fklanguages`
    FOREIGN KEY (`language_id`)
    REFERENCES `customers`.`languages` (`language_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `customers`.`customs_addresses`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`customs_addresses` (
  `custom_id` INT(10) UNSIGNED NOT NULL COMMENT 'Id клиента.',
  `address_id` INT(10) UNSIGNED NOT NULL COMMENT 'Id адреса клиента(может быть несколько).',
  INDEX `fkcustom_idx` (`custom_id` ASC) VISIBLE,
  INDEX `fkaddress_idx` (`address_id` ASC) VISIBLE,
  CONSTRAINT `fkaddress`
    FOREIGN KEY (`address_id`)
    REFERENCES `customers`.`addresses` (`address_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkcustom`
    FOREIGN KEY (`custom_id`)
    REFERENCES `customers`.`customs` (`custom_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `customers`.`gender`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`gender` (
  `gender_id` TINYINT(3) UNSIGNED NOT NULL COMMENT 'идентификатор пола (без индекса).Целостность за счет тригерра при insert.',
  `gender` VARCHAR(7) NULL DEFAULT NULL COMMENT 'Название пола(м или ж или не указан).')
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `customers`.`persons`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`persons` (
  `PersonId` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `FirstName` VARCHAR(12) NULL DEFAULT NULL,
  `LastName` VARCHAR(18) NULL DEFAULT NULL,
  `LanguageId` TINYINT(3) UNSIGNED NOT NULL,
  PRIMARY KEY (`PersonId`),
  INDEX `fklanguage_idx` (`LanguageId` ASC) VISIBLE,
  CONSTRAINT `fklanguage`
    FOREIGN KEY (`LanguageId`)
    REFERENCES `customers`.`languages` (`language_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `customers`.`shippers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`shippers` (
  `shipper_id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Ключ поставщика.',
  `shipper` VARCHAR(80) NOT NULL COMMENT 'Название поставщика.',
  `address` VARCHAR(100) NOT NULL COMMENT 'адрес поставщика.',
  `email` VARCHAR(18) NULL COMMENT 'email.может не быть.',
  PRIMARY KEY (`shipper_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `customers`.`manufacturers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`manufacturers` (
  `manufacturer_id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Ключ производителя товаров(а).',
  `manufacturer` VARCHAR(100) NOT NULL COMMENT 'Название производителя.',
  `address` VARCHAR(120) NOT NULL COMMENT 'Адрес производителя.',
  `email` VARCHAR(18) NULL COMMENT 'email.Может не быть.',
  `country` CHAR(2) NULL,
  PRIMARY KEY (`manufacturer_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `customers`.`categorys`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`categorys` (
  `category_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) NOT NULL,
  `parent` INT UNSIGNED NULL,
  PRIMARY KEY (`category_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `customers`.`dates`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`dates` (
  `date_id` BIGINT(24) UNSIGNED NOT NULL COMMENT 'Ключ для даты окончания ценового преложения.',
  `date` DATETIME NULL COMMENT 'Дата окончания ценового преложения.',
  PRIMARY KEY (`date_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `customers`.`products`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`products` (
  `product_id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Ключ продукта.',
  `name` VARCHAR(80) NULL COMMENT 'Название продукта.',
  `manufacturer_id` INT UNSIGNED ZEROFILL NOT NULL COMMENT 'Производитель продукта.',
  `category_id` INT UNSIGNED NOT NULL COMMENT 'Кюч категории к которой относится товар.',
  `date_max_id` BIGINT(24) UNSIGNED NOT NULL COMMENT 'Последняя дата окончания цены - нужно для проверки \nне пересечения временных интервалов изменения цены. ',
  PRIMARY KEY (`product_id`),
  INDEX `fk_products_manufacturers1_idx` (`manufacturer_id` ASC) VISIBLE,
  INDEX `fk_products_categorys1_idx` (`category_id` ASC) VISIBLE,
  INDEX `fk_products_date_idx` (`date_max_id` ASC) VISIBLE,
  CONSTRAINT `fk_products_manufacturers1`
    FOREIGN KEY (`manufacturer_id`)
    REFERENCES `customers`.`manufacturers` (`manufacturer_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_products_categorys1`
    FOREIGN KEY (`category_id`)
    REFERENCES `customers`.`categorys` (`category_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_products_date`
    FOREIGN KEY (`date_max_id`)
    REFERENCES `customers`.`dates` (`date_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `customers`.`currency`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`currency` (
  `currency_id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Ключ валюты.',
  `symbol` VARCHAR(1) CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_unicode_ci' NOT NULL COMMENT 'Знак валюты.',
  `short_name` VARCHAR(3) CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_unicode_ci' NOT NULL COMMENT 'Короткое имя валюты.',
  PRIMARY KEY (`currency_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `customers`.`buys`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`buys` (
  `custom_id` INT UNSIGNED NOT NULL COMMENT 'Ключ клиента,который купил. ',
  `product_id` INT UNSIGNED NOT NULL COMMENT 'Ключ продукта,который купили.',
  `date_buy` DATETIME NULL COMMENT 'Время и дата покупки.',
  `amount` DECIMAL NOT NULL COMMENT 'Цена в национальной валюте.',
  `unit` SMALLINT(3) ZEROFILL NULL COMMENT 'Количество штук.',
  `currency_id` INT UNSIGNED NOT NULL COMMENT 'Валюта покупки.',
  INDEX `fk_buys_products1_idx` (`product_id` ASC) VISIBLE,
  INDEX `fk_buys_currency_idx` (`currency_id` ASC) VISIBLE,
  INDEX `fk_buys_customs1_idx` (`custom_id` ASC) VISIBLE,
  CONSTRAINT `fk_buys_products1`
    FOREIGN KEY (`product_id`)
    REFERENCES `customers`.`products` (`product_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_buys_customs1`
    FOREIGN KEY (`custom_id`)
    REFERENCES `customers`.`customs` (`custom_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_buys_currency`
    FOREIGN KEY (`currency_id`)
    REFERENCES `customers`.`currency` (`currency_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `customers`.`attributes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`attributes` (
  `attribute_id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Ключ аттрибута.',
  `name` VARCHAR(80) NOT NULL COMMENT 'Имя аттрибута.',
  `type` VARCHAR(9) NOT NULL COMMENT 'Тип значения аттрибута.',
  `default_value` VARCHAR(12) CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_unicode_ci' NOT NULL COMMENT 'Значение по умолчанию.',
  `measurement_unit` VARCHAR(12) CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_unicode_ci' NOT NULL,
  PRIMARY KEY (`attribute_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `customers`.`products_attributes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`products_attributes` (
  `attribute_id` INT UNSIGNED NOT NULL COMMENT 'Внешний ключ на перв. ключ аттрибута.',
  `product_id` INT UNSIGNED NOT NULL COMMENT 'Внешний ключ на перв. ключ продукта.',
  `value_int` INT NULL COMMENT 'Содержит целочисленные значения.',
  `value_flt` FLOAT NULL COMMENT 'Содержит вещественные.Обычно тип float достаточен.',
  `value_varchar` VARCHAR(1000) NULL COMMENT 'Текст - используем varchar.',
  `value_datetime` DATETIME NULL COMMENT 'Дата и время.',
  `value_year` YEAR(4) NULL COMMENT 'Просто год.Например год выпуска продукта.',
  INDEX `fk_products_attributes_products1_idx` (`product_id` ASC) VISIBLE,
  INDEX `fk_products_attributes_attributes1_idx` (`attribute_id` ASC) VISIBLE,
  CONSTRAINT `fk_products_attributes_products1`
    FOREIGN KEY (`product_id`)
    REFERENCES `customers`.`products` (`product_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_products_attributes_attributes1`
    FOREIGN KEY (`attribute_id`)
    REFERENCES `customers`.`attributes` (`attribute_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `customers`.`prices`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`prices` (
  `price_id` BIGINT(24) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Кюч цены для некоторого продукта.',
  `product_id` INT UNSIGNED NOT NULL COMMENT 'Внешний ключ продукта.',
  `currency_id` INT UNSIGNED NOT NULL COMMENT 'Ключ базовой валюты.',
  `date_from` DATETIME NOT NULL COMMENT 'Дата выставления цены.',
  `date_to_id` BIGINT(24) UNSIGNED NOT NULL COMMENT 'Дата окончания действия текущей цены.',
  `amount_base` DECIMAL NOT NULL COMMENT 'Собственно значение цены в базовой валюте.Должна быть больше нуля.Реализовано через триггер before insert и before update.',
  PRIMARY KEY (`price_id`),
  INDEX `fk_Prices_products1_idx` (`product_id` ASC) VISIBLE,
  INDEX `fk_prices_currency_idx` (`currency_id` ASC) VISIBLE,
  INDEX `fk_prices_dates_idx` (`date_to_id` ASC) VISIBLE,
  CONSTRAINT `fk_Prices_products1`
    FOREIGN KEY (`product_id`)
    REFERENCES `customers`.`products` (`product_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_prices_currency`
    FOREIGN KEY (`currency_id`)
    REFERENCES `customers`.`currency` (`currency_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_prices_dates`
    FOREIGN KEY (`date_to_id`)
    REFERENCES `customers`.`dates` (`date_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `customers`.`shippers_products`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`shippers_products` (
  `shipper_id` INT UNSIGNED NOT NULL COMMENT 'Ключ поставщика.',
  `product_id` INT UNSIGNED NOT NULL COMMENT 'Ключ производителя.',
  INDEX `fk_shippers_products_products1_idx` (`product_id` ASC) VISIBLE,
  INDEX `fk_shippers_products_shippers1_idx` (`shipper_id` ASC) VISIBLE,
  CONSTRAINT `fk_shippers_products_products1`
    FOREIGN KEY (`product_id`)
    REFERENCES `customers`.`products` (`product_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_shippers_products_shippers1`
    FOREIGN KEY (`shipper_id`)
    REFERENCES `customers`.`shippers` (`shipper_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `customers`.`config`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`config` (
  `version` CHAR(3) NOT NULL COMMENT 'Версия модели БД.Просто номер 1,2, и т.д.')
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `customers`.`changes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`changes` (
  `currency_id` INT UNSIGNED NOT NULL COMMENT 'Ключ валюты.',
  `date` DATETIME NOT NULL COMMENT 'Дата курсы валюты по отношению к базовой.',
  `ratio` DECIMAL NULL COMMENT 'Курс валюты по отношению к базовой.',
  PRIMARY KEY (`currency_id`, `date`),
  CONSTRAINT `fk_changes_currency`
    FOREIGN KEY (`currency_id`)
    REFERENCES `customers`.`currency` (`currency_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

USE `customers` ;

-- -----------------------------------------------------
-- Placeholder table for view `customers`.`v_addresses`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`v_addresses` (`address_id` INT, `symbols` INT, `region` INT, `town` INT, `postalcode` INT, `street` INT, `house` INT);

-- -----------------------------------------------------
-- Placeholder table for view `customers`.`v_customs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`v_customs` (`custom_id` INT, `title` INT, `first_name` INT, `last_name` INT, `language` INT, `birthday` INT, `gender` INT, `marital_status` INT);

-- -----------------------------------------------------
-- Placeholder table for view `customers`.`v_products`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`v_products` (`product_id` INT, `name` INT, `manufacturer` INT, `amount_base` INT, `date_from` INT, `shipper` INT);

-- -----------------------------------------------------
-- Placeholder table for view `customers`.`v_customs_buys`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`v_customs_buys` (`first_name` INT, `last_name` INT, `name` INT, `amount` INT, `unit` INT, `date_buy` INT);

-- -----------------------------------------------------
-- Placeholder table for view `customers`.`v_attr`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers`.`v_attr` (`name` INT, `value` INT, `measure_unit` INT);

-- -----------------------------------------------------
-- View `customers`.`v_addresses`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `customers`.`v_addresses`;
USE `customers`;
CREATE  OR REPLACE VIEW `v_addresses` AS
select  a.address_id,cntr.symbols,reg.region,twn.town,pst.postalcode,str.street,a.house from addresses as a 
join substreets as s
on a.substreet_id=s.substreet_id
join streets as str
on s.street_id=str.street_id
join subtowns as stwn
on s.subtown_id=stwn.subtown_id
join towns as twn
on stwn.towns_id=twn.town_id
join postalcodes as pst
on pst.postalcode_id=stwn.post_id
join regions as reg
on reg.region_id=pst.region_id
join countrys as cntr
on cntr.country_id=reg.country_id;

-- -----------------------------------------------------
-- View `customers`.`v_customs`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `customers`.`v_customs`;
USE `customers`;
CREATE  OR REPLACE VIEW `v_customs` AS
select c.custom_id,title,c.first_name,c.last_name,l.language,c.birthday,g.gender,c.marital_status from customs as c
join titles as t
on c.title_id = t.title_id
join languages as l
on c.language_id=l.language_id
join gender as g
on c.gender = g.gender_id;

-- -----------------------------------------------------
-- View `customers`.`v_products`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `customers`.`v_products`;
USE `customers`;
CREATE  OR REPLACE VIEW `v_products` AS
select p.product_id,p.name,m.manufacturer,pr.amount_base,pr.date_from,sh.shipper from products as p 
join manufacturers as m
on p.manufacturer_id=m.manufacturer_id
join prices as pr
on p.product_id = pr.product_id
join shippers_products as shp
on shp.product_id=p.product_id
join shippers as sh
on sh.shipper_id=shp.shipper_id;

-- -----------------------------------------------------
-- View `customers`.`v_customs_buys`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `customers`.`v_customs_buys`;
USE `customers`;
CREATE  OR REPLACE VIEW `v_customs_buys` AS
select cust.first_name,cust.last_name,pr.name,b.amount,b.unit,b.date_buy from buys as b
join v_customs as cust
on b.custom_id=cust.custom_id
join products as pr
on pr.product_id=b.product_id;

-- -----------------------------------------------------
-- View `customers`.`v_attr`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `customers`.`v_attr`;
USE `customers`;
CREATE  OR REPLACE VIEW `v_attr` AS
select name,(CASE type  
                 WHEN 'Numfloat'  THEN v_flt
                 WHEN 'Numint'    THEN v_int
                END)value,measure_unit 
from (select name,a.type,pa.value_flt as v_flt,pa.value_int as v_int, a.measurement_unit as measure_unit from products_attributes as pa
join attributes as a
on pa.attribute_id=a.attribute_id
)A;
USE `customers`;

DELIMITER $$
USE `customers`$$
CREATE DEFINER = CURRENT_USER TRIGGER `customers`.`prices_BEFORE_INSERT` BEFORE INSERT ON `prices` FOR EACH ROW
BEGIN
     if new.amount_base <= 0.1 then
        set @msg = 'TriggerError: Trying to insert a amount <= 0.1: ';
        signal sqlstate '45000' set message_text = @msg;
    end if;
END$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
