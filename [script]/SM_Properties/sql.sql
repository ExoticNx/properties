-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.4.11-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             10.3.0.5771
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Dumping database structure for essentialmode
CREATE DATABASE IF NOT EXISTS `essentialmode` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin */;
USE `essentialmode`;

-- Dumping structure for table essentialmode.sm_owned_properties
CREATE TABLE IF NOT EXISTS `sm_owned_properties` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `price` double NOT NULL,
  `owner` varchar(60) NOT NULL,
  `locked` int(11) NOT NULL DEFAULT 1,
  `key1` varchar(60) NOT NULL,
  `key2` varchar(60) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table essentialmode.sm_owned_properties: ~3 rows (approximately)
/*!40000 ALTER TABLE `sm_owned_properties` DISABLE KEYS */;
/*!40000 ALTER TABLE `sm_owned_properties` ENABLE KEYS */;

-- Dumping structure for table essentialmode.sm_properties
CREATE TABLE IF NOT EXISTS `sm_properties` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_bin NOT NULL,
  `price` int(11) NOT NULL,
  `empty` int(1) NOT NULL DEFAULT 1,
  `max` int(11) NOT NULL DEFAULT 2,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;

-- Dumping data for table essentialmode.sm_properties: ~3 rows (approximately)
/*!40000 ALTER TABLE `sm_properties` DISABLE KEYS */;
INSERT INTO `sm_properties` (`id`, `name`, `price`, `empty`, `max`) VALUES
	(1, '123BrougeAvenue', 150000, 0, 2);
/*!40000 ALTER TABLE `sm_properties` ENABLE KEYS */;

-- Dumping structure for table essentialmode.sm_properties_items
CREATE TABLE IF NOT EXISTS `sm_properties_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `x` double NOT NULL DEFAULT 0,
  `y` double NOT NULL DEFAULT 0,
  `z` double NOT NULL DEFAULT 0,
  `item` varchar(50) NOT NULL,
  `label` varchar(50) NOT NULL,
  `type` varchar(50) NOT NULL,
  `count` int(11) NOT NULL,
  `amount` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=167 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table essentialmode.sm_properties_items: ~1 rows (approximately)
/*!40000 ALTER TABLE `sm_properties_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `sm_properties_items` ENABLE KEYS */;

-- Dumping structure for table essentialmode.sm_properties_objects
CREATE TABLE IF NOT EXISTS `sm_properties_objects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `owner` varchar(60) NOT NULL,
  `x` double NOT NULL DEFAULT 0,
  `y` double NOT NULL DEFAULT 0,
  `z` double NOT NULL DEFAULT 0,
  `r` float NOT NULL DEFAULT 0,
  `currentAmount` varchar(60) NOT NULL,
  `items` varchar(50) NOT NULL DEFAULT '0',
  `selected` int(11) NOT NULL DEFAULT 0,
  `spawned` int(11) NOT NULL DEFAULT 0,
  `locked` int(11) NOT NULL DEFAULT 1,
  `property` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=120 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

-- Dumping data for table essentialmode.sm_properties_objects: ~1 rows (approximately)
/*!40000 ALTER TABLE `sm_properties_objects` DISABLE KEYS */;
/*!40000 ALTER TABLE `sm_properties_objects` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
