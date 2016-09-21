CREATE DATABASE  IF NOT EXISTS `conference` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `conference`;
-- MySQL dump 10.13  Distrib 5.6.24, for Win32 (x86)
--
-- Host: localhost    Database: conference
-- ------------------------------------------------------
-- Server version	5.6.25-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Temporary view structure for view `all_students_kpi`
--

DROP TABLE IF EXISTS `all_students_kpi`;
/*!50001 DROP VIEW IF EXISTS `all_students_kpi`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `all_students_kpi` AS SELECT 
 1 AS `faculty`,
 1 AS `department`,
 1 AS `student_group`,
 1 AS `last_name`,
 1 AS `name`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `auditorium`
--

DROP TABLE IF EXISTS `auditorium`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auditorium` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL COMMENT 'Name of auditorium',
  `capacity` int(11) NOT NULL COMMENT 'capacity auditorium',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditorium`
--

LOCK TABLES `auditorium` WRITE;
/*!40000 ALTER TABLE `auditorium` DISABLE KEYS */;
INSERT INTO `auditorium` VALUES (1,'4-19',25),(2,'4-06',40),(3,'1-203-1',70),(4,'7-20',20),(5,'14-02',35),(6,'Большая Физическая',200);
/*!40000 ALTER TABLE `auditorium` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `conferee`
--

DROP TABLE IF EXISTS `conferee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `conferee` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `participant` int(11) NOT NULL COMMENT 'participant of conference',
  `sectional_day_id` int(11) NOT NULL,
  `date_reg` datetime DEFAULT NULL COMMENT 'date of registration at the conference',
  PRIMARY KEY (`id`),
  KEY `fk_conferee_sectional_day1_idx` (`sectional_day_id`),
  KEY `fk_conferee_participant1_idx` (`participant`),
  CONSTRAINT `fk_conferee_participant1` FOREIGN KEY (`participant`) REFERENCES `human` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_conferee_sectional_day1` FOREIGN KEY (`sectional_day_id`) REFERENCES `sectional_day` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conferee`
--

LOCK TABLES `conferee` WRITE;
/*!40000 ALTER TABLE `conferee` DISABLE KEYS */;
INSERT INTO `conferee` VALUES (1,1,4,'2016-05-11 09:10:00'),(13,2,4,'2016-05-11 10:00:00'),(14,3,4,'2016-05-11 09:15:00'),(15,4,5,NULL),(16,5,5,NULL),(17,6,6,NULL),(18,7,7,NULL),(19,8,7,NULL),(20,9,7,NULL),(21,10,4,'2016-05-11 09:12:00'),(22,11,4,NULL),(23,12,4,NULL),(24,13,4,NULL),(25,14,4,NULL),(26,15,4,NULL),(27,16,4,NULL),(28,17,4,NULL),(29,18,4,NULL),(30,19,4,NULL),(31,20,4,NULL),(32,21,4,NULL),(33,22,4,NULL),(34,32,4,NULL);
/*!40000 ALTER TABLE `conferee` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `conference`.`conferee_BEFORE_INSERT` BEFORE INSERT ON `conferee` FOR EACH ROW BEGIN
DECLARE registr INT;
DECLARE all_conferee INT;
DECLARE count_conferee INT;

SELECT
	COUNT(*)
FROM conferee
	JOIN sectional_day ON sectional_day.id = conferee.sectional_day_id
	JOIN reserve_auditorium AS r ON r.id = sectional_day.reserve_auditorium_id
WHERE sectional_day.id = NEW.sectional_day_id AND NOT (
	NEW.date_reg BETWEEN r.begin AND r.end)
INTO registr;  
IF registr > 0 THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Time out for registration in this day';
END IF;

SELECT
	COUNT(*)
FROM conferee
WHERE conferee.sectional_day_id = NEW.sectional_day_id
GROUP BY sectional_day_id
INTO all_conferee;
IF all_conferee + 1 > (
	SELECT
		auditorium.capacity
	FROM conferee    
		JOIN sectional_day ON sectional_day.id = conferee.sectional_day_id
		JOIN reserve_auditorium ON reserve_auditorium.id = sectional_day.reserve_auditorium_id
		JOIN auditorium ON auditorium.id = reserve_auditorium.auditorium_id
	WHERE conferee.sectional_day_id = NEW.sectional_day_id
	GROUP BY auditorium.id)
THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Many conferee for such auditorium';
END IF;

SELECT
	COUNT(*)
FROM conferee
WHERE conferee.participant = NEW.participant AND
	conferee.sectional_day_id = NEW.sectional_day_id
INTO count_conferee;
IF count_conferee > 0 THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Can"t registration twice conferee in this day';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `conference`.`conferee_AFTER_INSERT` 
AFTER INSERT ON `conferee` FOR EACH ROW
BEGIN
UPDATE sectional_day
	SET number = number + 1
WHERE sectional_day.id = NEW.sectional_day_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `conference`.`conferee_BEFORE_UPDATE` 
BEFORE UPDATE ON `conferee` FOR EACH ROW
BEGIN
DECLARE registr INT;
SELECT
	COUNT(*)
FROM conferee
	JOIN sectional_day ON sectional_day.id = conferee.sectional_day_id
	JOIN reserve_auditorium AS r ON r.id = sectional_day.reserve_auditorium_id
WHERE sectional_day.id = OLD.sectional_day_id AND NOT (
	NEW.date_reg BETWEEN r.begin AND r.end)
INTO registr;  
IF registr > 0 THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Time out for registration in this day';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `conference`.`conferee_AFTER_DELETE` 
AFTER DELETE ON `conferee` FOR EACH ROW
BEGIN
UPDATE sectional_day
	SET number = number - 1
WHERE sectional_day.id = OLD.sectional_day_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `conferee_has_report`
--

DROP TABLE IF EXISTS `conferee_has_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `conferee_has_report` (
  `conferee_id` int(11) NOT NULL,
  `report_id` int(11) NOT NULL,
  PRIMARY KEY (`conferee_id`,`report_id`),
  KEY `fk_conferee_has_report_report1_idx` (`report_id`),
  KEY `fk_conferee_has_report_conferee1_idx` (`conferee_id`),
  CONSTRAINT `fk_conferee_has_report_conferee1` FOREIGN KEY (`conferee_id`) REFERENCES `conferee` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_conferee_has_report_report1` FOREIGN KEY (`report_id`) REFERENCES `report` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conferee_has_report`
--

LOCK TABLES `conferee_has_report` WRITE;
/*!40000 ALTER TABLE `conferee_has_report` DISABLE KEYS */;
INSERT INTO `conferee_has_report` VALUES (1,1),(13,2),(18,3),(19,3),(18,4);
/*!40000 ALTER TABLE `conferee_has_report` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `conference`.`conferee_has_report_BEFORE_INSERT` 
BEFORE INSERT ON `conferee_has_report` FOR EACH ROW
BEGIN
DECLARE count_report_day INT;
DECLARE count_report_conferee INT;
DECLARE count_autor_report INT;

SELECT COUNT(*) 
FROM conferee
	JOIN conferee_has_report ON conferee_has_report.conferee_id = conferee.id 
	JOIN report ON report.id = conferee_has_report.report_id
	JOIN sectional_day ON sectional_day.id = conferee.sectional_day_id
WHERE sectional_day.id = (
	SELECT DISTINCT conferee.sectional_day_id 
		FROM conferee_has_report
    JOIN conferee ON conferee_has_report.conferee_id = conferee.id
    WHERE conferee_has_report.conferee_id = NEW.conferee_id
	)
GROUP BY report.id
INTO count_report_day;
IF count_report_day > 10 THEN
		signal sqlstate '45000' set message_text = 'Error: too many report in one day';
END IF;

SELECT COUNT(*) FROM (
	SELECT 
		COUNT(*) 
	FROM  conferee_has_report
		JOIN conferee ON conferee_has_report.conferee_id = conferee.id 
	WHERE conferee.id = NEW.conferee_id
	GROUP BY conferee_has_report.report_id
	) AS t1
INTO count_report_conferee;
IF count_report_conferee > 2 THEN
		signal sqlstate '45000' set message_text = 'Error: Too many reports by one conferee';
END IF;

SELECT 
	COUNT(*) 
FROM conferee_has_report
WHERE report_id = NEW.report_id
GROUP BY report_id
INTO count_autor_report;
	
IF count_autor_report > 3 THEN
		signal sqlstate '45000' set message_text = 'Error: Too many autors for one report';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `conference`.`conferee_has_report_AFTER_INSERT` 
AFTER INSERT ON `conferee_has_report` FOR EACH ROW
BEGIN
UPDATE human
	SET number_reports = number_reports + 1
WHERE human.id = (
	SELECT DISTINCT conferee.participant 
    FROM conferee_has_report
		JOIN conferee ON conferee.id = conferee_has_report.conferee_id
	WHERE conferee.id = NEW.conferee_id 
);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `conference`.`conferee_has_report_AFTER_DELETE` 
AFTER DELETE ON `conferee_has_report` FOR EACH ROW
BEGIN
UPDATE human
	SET number_reports = number_reports - 1
WHERE human.id = (
	SELECT DISTINCT conferee.participant 
	FROM conferee_has_report
		JOIN conferee ON conferee.id = conferee_has_report.conferee_id
	WHERE conferee.id = OLD.conferee_id 
);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `department`
--

DROP TABLE IF EXISTS `department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `department` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT 'Name of Department',
  `faculty_id` int(11) NOT NULL COMMENT 'Faculty owns Department',
  `head` int(11) DEFAULT NULL COMMENT 'Head of Department',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`),
  KEY `fk_department_faculty1_idx` (`faculty_id`),
  KEY `fk_department_human1_idx` (`head`),
  CONSTRAINT `fk_department_faculty1` FOREIGN KEY (`faculty_id`) REFERENCES `faculty` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_department_human1` FOREIGN KEY (`head`) REFERENCES `human` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `department`
--

LOCK TABLES `department` WRITE;
/*!40000 ALTER TABLE `department` DISABLE KEYS */;
INSERT INTO `department` VALUES (1,'Кафедра автоматизации проектирования энергетических процессов и систем',1,NULL),(2,'Кафедра автоматизации теплоэнергетических процессов',1,NULL),(3,'Кафедра теоретических основ радиотехники',2,NULL),(4,'Кафедра радиоприема и обработки сигналов',2,NULL),(5,'Кафедра приборостроения',3,NULL),(6,'Кафедра производства приборов',3,NULL),(7,'Кафедра теоретической кибернетики',4,NULL),(8,'Кафедра алгебры и математической логики',5,NULL),(9,'Кафедра давней и новой истории Украины',6,NULL),(10,'Кафедра археологии',6,NULL),(11,'Кафедра экономики предприятия',7,NULL),(12,'Кафедра экономической кибернетики',7,NULL);
/*!40000 ALTER TABLE `department` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `conference`.`department_BEFORE_INSERT` BEFORE INSERT ON `department` FOR EACH ROW
BEGIN
DECLARE real_head INT;

SELECT
	COUNT(*)
FROM teacher
WHERE teacher.human_id = NEW.head AND 
	(teacher.science_degree = 'DOCTOR_OF_SCIENCES' 
	OR teacher.science_degree = 'CANDIDATE_OF_SCIENCES') 
INTO real_head;

IF real_head = 0 THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: This Tacher can"t be head of department';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `equipment`
--

DROP TABLE IF EXISTS `equipment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `equipment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL COMMENT 'Name of equipment',
  `auditorium_id` int(11) NOT NULL COMMENT 'The auditorium for which the fixed equipment',
  PRIMARY KEY (`id`),
  KEY `fk_equipment_auditorium1_idx` (`auditorium_id`),
  KEY `equipment_name` (`name`),
  CONSTRAINT `fk_equipment_auditorium1` FOREIGN KEY (`auditorium_id`) REFERENCES `auditorium` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equipment`
--

LOCK TABLES `equipment` WRITE;
/*!40000 ALTER TABLE `equipment` DISABLE KEYS */;
INSERT INTO `equipment` VALUES (1,'Проектор',1),(2,'Проектор',2),(3,'Проектор',3),(4,'Проектор',4),(5,'Проектор',6),(6,'Указка',1),(7,'Указка',5),(8,'Указка',6),(9,'Микрофон',6),(10,'Указка',2),(11,'Указка',3),(12,'Указка',4);
/*!40000 ALTER TABLE `equipment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `faculty`
--

DROP TABLE IF EXISTS `faculty`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `faculty` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT 'Name of Faculty',
  `university_id` int(11) NOT NULL COMMENT 'University owns the faculty',
  `dean` int(11) DEFAULT NULL COMMENT 'Dean od Faculty',
  PRIMARY KEY (`id`),
  KEY `fk_faculty_university1_idx` (`university_id`),
  KEY `fk_faculty_human1_idx` (`dean`),
  KEY `faculty_name` (`name`),
  CONSTRAINT `fk_faculty_human1` FOREIGN KEY (`dean`) REFERENCES `human` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_faculty_university1` FOREIGN KEY (`university_id`) REFERENCES `university` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `faculty`
--

LOCK TABLES `faculty` WRITE;
/*!40000 ALTER TABLE `faculty` DISABLE KEYS */;
INSERT INTO `faculty` VALUES (1,'Теплоэнергетический факультет',1,38),(2,'Радиотехнический факультет',1,NULL),(3,'Приборостроительный факультет',1,40),(4,'Факультет кибернетики',2,NULL),(5,'Механико-математический факультет',2,NULL),(6,'Исторический факультет',2,NULL),(7,'Экономический факультет',2,NULL),(8,'Факультет компьютерных систем',3,NULL),(9,'Факультет телекоммуникаций и защиты информации',3,NULL);
/*!40000 ALTER TABLE `faculty` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `conference`.`faculty_BEFORE_INSERT` BEFORE INSERT ON `faculty` FOR EACH ROW
BEGIN

DECLARE real_dean INT;

SELECT
	COUNT(*)
FROM teacher
WHERE teacher.human_id = NEW.dean AND 
		(teacher.science_degree = 'DOCTOR_OF_SCIENCES') AND 
		(teacher.position = 'PROFESSOR' OR teacher.position = 'ASSOCIATE_PROFESSOR')
INTO real_dean;

IF real_dean = 0 THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: This Tacher can"t be dean';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `human`
--

DROP TABLE IF EXISTS `human`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `human` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `last_name` varchar(45) NOT NULL,
  `number_reports` int(11) DEFAULT '0' COMMENT 'number of reports in conference',
  PRIMARY KEY (`id`),
  KEY `human_name_last_name` (`name`,`last_name`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `human`
--

LOCK TABLES `human` WRITE;
/*!40000 ALTER TABLE `human` DISABLE KEYS */;
INSERT INTO `human` VALUES (1,'Матвей','Захаров',1),(2,'Александр','Симонов',1),(3,'Артём','Сафонов',0),(4,'Глеб','Алексеев',0),(5,'Антон','Мамонтов',0),(6,'Семён','Титов',0),(7,'Матвей','Шубин',2),(8,'Виталий','Панов',6),(9,'Иван','Сорокин',0),(10,'Семён','Фадеев',0),(11,'Анатолий','Тарасов',0),(12,'Илья','Анисимов',0),(13,'Станислав','Харитонов',0),(14,'Святослав','Бобылёв',0),(15,'Сергей','Молчанов',0),(16,'Илья','Некрасов',0),(17,'Лев','Александров',0),(18,'Вадим','Жданов',0),(19,'Леонид','Ильин',0),(20,'Евгений','Данилов',0),(21,'Максим','Гордеев',0),(22,'Александр','Лапин',0),(23,'Григорий','Самсонов',0),(24,'Лев','Мамонтов',0),(25,'Денис','Ковалёв',0),(26,'Николай','Гущин',0),(27,'Никита','Стрелков',0),(28,'Роман','Зуев',0),(29,'Павел','Владимиров',0),(30,'Илья','Николаев',0),(31,'Георгий','Морозов',0),(32,'Владимир','Самсонов',0),(33,'Валерий','Тетерин',0),(34,'Гавриил','Муравьёв',0),(35,'Егор','Белоусов',0),(36,'Павел','Логинов',0),(37,'Сергей','Вишняков',0),(38,'Евгений','Письменный',0),(39,'Михаил','Згуровский',0),(40,'Григорий','Тымчик',0),(41,'Леонид','Губерский',0);
/*!40000 ALTER TABLE `human` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `postgraduate`
--

DROP TABLE IF EXISTS `postgraduate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `postgraduate` (
  `human_id` int(11) NOT NULL,
  `department_id` int(11) NOT NULL COMMENT 'Department of postgraduate',
  `supervisor` int(11) NOT NULL COMMENT 'supervisor of postgraduate',
  PRIMARY KEY (`human_id`),
  KEY `fk_postgraduate_department1_idx` (`department_id`),
  KEY `fk_postgraduate_teacher1_idx` (`supervisor`),
  CONSTRAINT `fk_postgraduate_department1` FOREIGN KEY (`department_id`) REFERENCES `department` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_postgraduate_human1` FOREIGN KEY (`human_id`) REFERENCES `human` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_postgraduate_teacher1` FOREIGN KEY (`supervisor`) REFERENCES `teacher` (`human_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `postgraduate`
--

LOCK TABLES `postgraduate` WRITE;
/*!40000 ALTER TABLE `postgraduate` DISABLE KEYS */;
INSERT INTO `postgraduate` VALUES (31,8,38),(32,4,33),(34,4,33),(35,7,36),(37,10,36);
/*!40000 ALTER TABLE `postgraduate` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report`
--

DROP TABLE IF EXISTS `report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL COMMENT 'Title of report',
  `novelty` varchar(200) NOT NULL COMMENT 'novelty of report',
  `time` int(11) NOT NULL COMMENT 'the actual time of the report in minutes',
  PRIMARY KEY (`id`),
  UNIQUE KEY `title_UNIQUE` (`title`),
  KEY `report_title` (`title`),
  KEY `report_title_novelty` (`title`,`novelty`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report`
--

LOCK TABLES `report` WRITE;
/*!40000 ALTER TABLE `report` DISABLE KEYS */;
INSERT INTO `report` VALUES (1,'Анализ методов расчёта и синтеза шарнирно - сочленённой стреловой системы портального крана','Ввлияние на эксплуатационные характеристики портального крана',15),(2,'Технические аспекты проектирования устройства для определения нестабильности обратных токов переходов полупроводниковых приборов','Средства измерений и контроля различных параметров изделий и процессо',14),(3,'Функциональные особенности автоматизированных информационных систем управления предприятием','Информационные системы и технологии в крупных фирмах и государственных учреждениях',10),(4,'Имитационная модель организационно-технической системы как средство обучения руководителя','Имитационная модель организационно-технической системы',19),(5,'Математическая модель поведения активного элемента в сетевых структурах планирования распределения финансовых ресурсов','Математическая модель поведения активного элемента',15),(6,'Исследование электроразрядных эксимерных лазеров','Эксимерный лазер',13),(7,'Озонный механизм электромагнитног о предвестника землетрясений','Прогноз катастрофических событий',9),(8,'Времяпролетная диагностика параметров импульсных ионных пучков','Воздействие импульсных ионных пучков',16),(9,'Расчет распределения поля электрической напряженности пробной волны импульсной рефлектометрии плазмы','Импульсная  СВЧ ',13),(10,'Электроискровое диспергирование алюминиевой загрузки','Электроискровое диспергирование металлических загруз',15);
/*!40000 ALTER TABLE `report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reports_archive`
--

DROP TABLE IF EXISTS `reports_archive`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports_archive` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL COMMENT 'Title of report',
  `novelty` varchar(200) NOT NULL COMMENT 'novelty of report',
  `autors` varchar(200) NOT NULL,
  `reports_collection_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `title_UNIQUE` (`title`),
  KEY `fk_reports_collection_idx` (`reports_collection_id`),
  KEY `reports_archive_title` (`title`),
  KEY `reports_archive_title_novetly` (`title`,`novelty`),
  KEY `reports_archive_autors` (`autors`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports_archive`
--

LOCK TABLES `reports_archive` WRITE;
/*!40000 ALTER TABLE `reports_archive` DISABLE KEYS */;
INSERT INTO `reports_archive` VALUES (15,'Анализ методов расчёта и синтеза шарнирно - сочленённой стреловой системы портального крана','Ввлияние на эксплуатационные характеристики портального крана','Захаров Матвей',3),(16,'Технические аспекты проектирования устройства для определения нестабильности обратных токов переходов полупроводниковых приборов','Средства измерений и контроля различных параметров изделий и процессо','Симонов Александр',3),(17,'Функциональные особенности автоматизированных информационных систем управления предприятием','Информационные системы и технологии в крупных фирмах и государственных учреждениях','Панов Виталий, Шубин Матвей',3),(18,'Имитационная модель организационно-технической системы как средство обучения руководителя','Имитационная модель организационно-технической системы','Шубин Матвей',3);
/*!40000 ALTER TABLE `reports_archive` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reports_collection`
--

DROP TABLE IF EXISTS `reports_collection`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports_collection` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL COMMENT 'the scientific name of a collection of conference materials',
  `number` int(11) DEFAULT NULL COMMENT 'Conference reports collection number',
  `pages` int(11) DEFAULT '0' COMMENT 'number of  Conference reports collection',
  `year` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `reports_collection_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports_collection`
--

LOCK TABLES `reports_collection` WRITE;
/*!40000 ALTER TABLE `reports_collection` DISABLE KEYS */;
INSERT INTO `reports_collection` VALUES (2,'Техника',1,0,2016),(3,'Точные науки',2,0,2016);
/*!40000 ALTER TABLE `reports_collection` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reserve_auditorium`
--

DROP TABLE IF EXISTS `reserve_auditorium`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reserve_auditorium` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `auditorium_id` int(11) NOT NULL COMMENT 'auditorium that are reserved',
  `begin` datetime NOT NULL COMMENT 'The date and time at which the auditorium will be busy',
  `end` datetime NOT NULL COMMENT 'The date and time at which the auditorium is free',
  PRIMARY KEY (`id`),
  KEY `fk_reserve_auditorium_auditorium1_idx` (`auditorium_id`),
  CONSTRAINT `fk_reserve_auditorium_auditorium1` FOREIGN KEY (`auditorium_id`) REFERENCES `auditorium` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reserve_auditorium`
--

LOCK TABLES `reserve_auditorium` WRITE;
/*!40000 ALTER TABLE `reserve_auditorium` DISABLE KEYS */;
INSERT INTO `reserve_auditorium` VALUES (1,3,'2016-05-11 09:00:00','2016-05-11 13:00:00'),(2,1,'2016-05-11 09:00:00','2016-05-11 13:00:00'),(3,2,'2016-05-11 09:00:00','2016-05-11 13:00:00'),(4,4,'2016-05-11 09:00:00','2016-05-11 16:00:00'),(5,5,'2016-05-11 10:00:00','2016-05-11 16:00:00');
/*!40000 ALTER TABLE `reserve_auditorium` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `conference`.`reserve_auditorium_BEFORE_INSERT` 
BEFORE INSERT ON `reserve_auditorium` FOR EACH ROW
BEGIN
DECLARE auditorium_reserv INT;

SELECT
    COUNT(*)
FROM reserve_auditorium AS r
WHERE r.auditorium_id = NEW.auditorium_id AND 
	(
 	NEW.begin BETWEEN r.begin AND r.end 
	OR NEW.begin BETWEEN r.begin AND r.end
    )
INTO auditorium_reserv;  

IF auditorium_reserv > 0 THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Intersection of auditorium reserv';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `section`
--

DROP TABLE IF EXISTS `section`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `section` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(150) NOT NULL COMMENT 'conference title section',
  `topic_id` int(11) NOT NULL COMMENT 'topics to which the section of the conference',
  `head` int(11) NOT NULL COMMENT 'Head of section',
  PRIMARY KEY (`id`),
  UNIQUE KEY `title_UNIQUE` (`title`),
  KEY `fk_section_topic1_idx` (`topic_id`),
  KEY `fk_section_human1_idx` (`head`),
  KEY `section_title` (`title`),
  CONSTRAINT `fk_section_human1` FOREIGN KEY (`head`) REFERENCES `human` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_section_topic1` FOREIGN KEY (`topic_id`) REFERENCES `topic` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `section`
--

LOCK TABLES `section` WRITE;
/*!40000 ALTER TABLE `section` DISABLE KEYS */;
INSERT INTO `section` VALUES (1,'Современное машиностроение: проблемы и тенденции развития',1,40),(2,'Системный анализ, управление и обработка информации',2,39),(3,'Энергообеспечение и энергосбережение в промышленности.',1,32),(4,'Новое в развитии информационных технологий и коммуникаций.',2,36);
/*!40000 ALTER TABLE `section` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sectional_day`
--

DROP TABLE IF EXISTS `sectional_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sectional_day` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL COMMENT 'Ordinal name of sectional day',
  `section_id` int(11) NOT NULL COMMENT 'section of day',
  `reserve_auditorium_id` int(11) NOT NULL COMMENT 'reserve auditorium of section in this day',
  `start` date DEFAULT NULL COMMENT 'begin of sectional day',
  `finish` date DEFAULT NULL COMMENT 'end of sectional day',
  `number` int(11) DEFAULT '0' COMMENT 'The number of registered participants',
  PRIMARY KEY (`id`),
  KEY `fk_sectional_day_section1_idx` (`section_id`),
  KEY `fk_sectional_day_reserve_auditorium1_idx1` (`reserve_auditorium_id`),
  CONSTRAINT `fk_sectional_day_reserve_auditorium1` FOREIGN KEY (`reserve_auditorium_id`) REFERENCES `reserve_auditorium` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sectional_day_section1` FOREIGN KEY (`section_id`) REFERENCES `section` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sectional_day`
--

LOCK TABLES `sectional_day` WRITE;
/*!40000 ALTER TABLE `sectional_day` DISABLE KEYS */;
INSERT INTO `sectional_day` VALUES (4,'Первый СМ',1,1,NULL,NULL,17),(5,'Первый ЕЕ',3,4,NULL,NULL,2),(6,'Первый СА',2,3,NULL,NULL,1),(7,'Первый НИ',4,2,NULL,NULL,3);
/*!40000 ALTER TABLE `sectional_day` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student`
--

DROP TABLE IF EXISTS `student`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `student` (
  `human_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL COMMENT 'Group of Student',
  PRIMARY KEY (`human_id`),
  KEY `fk_student_group1_idx` (`group_id`),
  CONSTRAINT `fk_student_group1` FOREIGN KEY (`group_id`) REFERENCES `student_group` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_student_human` FOREIGN KEY (`human_id`) REFERENCES `human` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student`
--

LOCK TABLES `student` WRITE;
/*!40000 ALTER TABLE `student` DISABLE KEYS */;
INSERT INTO `student` VALUES (2,2),(3,2),(4,2),(5,3),(6,3),(7,4),(8,4),(9,4),(10,4),(11,4),(12,5),(13,6),(14,6),(15,6),(16,6),(17,6),(18,6),(19,6),(20,6),(21,6),(22,6),(23,7),(24,7),(25,7),(26,7),(27,7),(28,7),(29,7),(30,7);
/*!40000 ALTER TABLE `student` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `conference`.`student_BEFORE_INSERT` 
BEFORE INSERT ON `student` FOR EACH ROW
BEGIN
DECLARE count_student INT;

SELECT
	count
FROM student_group 
WHERE student_group.id = NEW.group_id
INTO count_student;

IF count_student > 30 THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Too many student in this group (30)';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `conference`.`student_AFTER_INSERT` 
AFTER INSERT ON `student` FOR EACH ROW
BEGIN

UPDATE student_group
	SET count = count + 1
WHERE student_group.id = NEW.group_id;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `student_group`
--

DROP TABLE IF EXISTS `student_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `student_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL COMMENT 'name of student group',
  `department_id` int(11) NOT NULL COMMENT 'department of the group',
  `count` int(11) DEFAULT NULL COMMENT 'the number of students in the group',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`),
  KEY `fk_group_department1_idx` (`department_id`),
  KEY `student_group_name` (`name`),
  CONSTRAINT `fk_group_department1` FOREIGN KEY (`department_id`) REFERENCES `department` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_group`
--

LOCK TABLES `student_group` WRITE;
/*!40000 ALTER TABLE `student_group` DISABLE KEYS */;
INSERT INTO `student_group` VALUES (1,'ТМ-91',1,NULL),(2,'ТВ-82',1,NULL),(3,'РТ-51',4,NULL),(4,'РА-31',4,NULL),(5,'ПБ-41',6,NULL),(6,'ПМ-31',5,NULL),(7,'К-14',7,NULL);
/*!40000 ALTER TABLE `student_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teacher`
--

DROP TABLE IF EXISTS `teacher`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `teacher` (
  `human_id` int(11) NOT NULL,
  `department_id` int(11) NOT NULL COMMENT 'Department of teacher',
  `science_degree` enum('WITHOUT','CANDIDATE_OF_SCIENCES','DOCTOR_OF_SCIENCES') DEFAULT 'WITHOUT' COMMENT 'science degree of teacher',
  `position` enum('PROFESSOR','ASSOCIATE_PROFESSOR','ASSISTANT_PROFESSOR') DEFAULT NULL COMMENT 'position in the department, which takes teacher',
  PRIMARY KEY (`human_id`),
  KEY `fk_teacher_department1_idx` (`department_id`),
  CONSTRAINT `fk_teacher_department1` FOREIGN KEY (`department_id`) REFERENCES `department` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_teacher_human1` FOREIGN KEY (`human_id`) REFERENCES `human` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teacher`
--

LOCK TABLES `teacher` WRITE;
/*!40000 ALTER TABLE `teacher` DISABLE KEYS */;
INSERT INTO `teacher` VALUES (33,4,'CANDIDATE_OF_SCIENCES','ASSOCIATE_PROFESSOR'),(36,8,'CANDIDATE_OF_SCIENCES','ASSISTANT_PROFESSOR'),(38,1,'DOCTOR_OF_SCIENCES','PROFESSOR'),(39,2,'DOCTOR_OF_SCIENCES','PROFESSOR'),(40,6,'DOCTOR_OF_SCIENCES','PROFESSOR'),(41,9,'DOCTOR_OF_SCIENCES','PROFESSOR');
/*!40000 ALTER TABLE `teacher` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `topic`
--

DROP TABLE IF EXISTS `topic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `topic` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL COMMENT 'the name of the conference topics',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`),
  KEY `topic_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `topic`
--

LOCK TABLES `topic` WRITE;
/*!40000 ALTER TABLE `topic` DISABLE KEYS */;
INSERT INTO `topic` VALUES (2,'Информационные технологии'),(1,'Технические науки');
/*!40000 ALTER TABLE `topic` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `university`
--

DROP TABLE IF EXISTS `university`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `university` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL COMMENT 'Full Name of  University',
  `short_name` varchar(45) DEFAULT NULL COMMENT 'Name Abbreviation of University',
  `founding_year` int(11) DEFAULT NULL COMMENT 'Founding Year of University',
  `rector` int(11) DEFAULT NULL COMMENT 'Rector of University',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`),
  KEY `fk_university_human1_idx` (`rector`),
  KEY `university_name` (`name`),
  KEY `university_short_name` (`short_name`),
  CONSTRAINT `fk_university_human1` FOREIGN KEY (`rector`) REFERENCES `human` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `university`
--

LOCK TABLES `university` WRITE;
/*!40000 ALTER TABLE `university` DISABLE KEYS */;
INSERT INTO `university` VALUES (1,'Национальный технический университет Украины \"КПИ\"','НТУУ\"КПИ\"',1898,39),(2,'Киевский национальный университет имени Тараса Шевченко','КНУ',1834,NULL),(3,'Национальный авиационный университет','НАУ',1933,NULL);
/*!40000 ALTER TABLE `university` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `conference`.`university_BEFORE_INSERT` 
BEFORE INSERT ON `university` FOR EACH ROW
BEGIN

DECLARE real_rector INT;

SELECT
	COUNT(*)
FROM teacher
WHERE teacher.human_id = NEW.rector AND 
	(teacher.science_degree = 'DOCTOR_OF_SCIENCES') AND 
	(teacher.position = 'PROFESSOR')
INTO real_rector;

IF real_rector = 0 THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: This Tacher can"t be rector';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary view structure for view `view_all_teacher`
--

DROP TABLE IF EXISTS `view_all_teacher`;
/*!50001 DROP VIEW IF EXISTS `view_all_teacher`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `view_all_teacher` AS SELECT 
 1 AS `university`,
 1 AS `faculty`,
 1 AS `department`,
 1 AS `last_name`,
 1 AS `name`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `view_sections`
--

DROP TABLE IF EXISTS `view_sections`;
/*!50001 DROP VIEW IF EXISTS `view_sections`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `view_sections` AS SELECT 
 1 AS `title`,
 1 AS `day`,
 1 AS `name`,
 1 AS `last_name`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'conference'
--

--
-- Dumping routines for database 'conference'
--
/*!50003 DROP PROCEDURE IF EXISTS `cp_finish_day` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `cp_finish_day`(IN current_sectional_day INT)
BEGIN
UPDATE sectional_day
	SET finish = NOW()
WHERE sectional_day.id = current_sectional_day;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `cp_reg_conferee` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `cp_reg_conferee`(IN current_conferee INT)
BEGIN

UPDATE conferee
	SET date_reg = NOW()
WHERE conferee.id = current_conferee;
-- OR WHERE conferee.participant = current_human;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `cp_start_day` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `cp_start_day`(IN current_sectional_day INT)
BEGIN
UPDATE sectional_day
	SET start = NOW()
WHERE sectional_day.id = current_sectional_day;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_confecence` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_confecence`()
BEGIN

TRUNCATE TABLE reserve_auditorium;

TRUNCATE TABLE sectional_day;

TRUNCATE TABLE conferee;

TRUNCATE TABLE conferee_has_report;

TRUNCATE TABLE report;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `make_reports_collection` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `make_reports_collection`(IN collection_name VARCHAR(45), IN collection_number INT)
BEGIN
DECLARE current_year INT;
DECLARE current_collection_id INT;

SET current_year = YEAR(NOW());

INSERT INTO
reports_collection 
(name, number, year) 
VALUES
(collection_name, collection_number, current_year);

SET current_collection_id = LAST_INSETR_ID();

INSERT INTO
reports_archive
(title, novelty, autors, reports_collection_id)
SELECT
	title,
	novelty,
	GROUP_CONCAT(last_name,' ', name  SEPARATOR ', ') as 'autors',
	current_collection_id
FROM report
	JOIN conferee_has_report ON conferee_has_report.report_id = report.id
	JOIN conferee ON conferee.id = conferee_has_report.conferee_id
	JOIN human ON human.id = conferee.participant
GROUP BY report.id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `all_students_kpi`
--

/*!50001 DROP VIEW IF EXISTS `all_students_kpi`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `all_students_kpi` AS (select `faculty`.`name` AS `faculty`,`department`.`name` AS `department`,`student_group`.`name` AS `student_group`,`human`.`last_name` AS `last_name`,`human`.`name` AS `name` from ((((`human` join `student` on((`student`.`human_id` = `human`.`id`))) join `student_group` on((`student_group`.`id` = `student`.`group_id`))) join `department` on((`department`.`id` = `student_group`.`department_id`))) join `faculty` on((`faculty`.`id` = `department`.`faculty_id`))) where (`faculty`.`university_id` = 1) group by `faculty`,`department`,`student_group`,`human`.`id`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_all_teacher`
--

/*!50001 DROP VIEW IF EXISTS `view_all_teacher`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_all_teacher` AS (select `university`.`name` AS `university`,`faculty`.`name` AS `faculty`,`department`.`name` AS `department`,`human`.`last_name` AS `last_name`,`human`.`name` AS `name` from ((((`human` join `teacher` on((`teacher`.`human_id` = `human`.`id`))) join `department` on((`department`.`id` = `teacher`.`department_id`))) join `faculty` on((`faculty`.`id` = `department`.`faculty_id`))) join `university` on((`university`.`id` = `faculty`.`university_id`)))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_sections`
--

/*!50001 DROP VIEW IF EXISTS `view_sections`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_sections` AS select `section`.`title` AS `title`,`sectional_day`.`name` AS `day`,`human`.`name` AS `name`,`human`.`last_name` AS `last_name` from (((`section` join `sectional_day` on((`sectional_day`.`section_id` = `section`.`id`))) join `conferee` on((`sectional_day`.`id` = `conferee`.`sectional_day_id`))) join `human` on((`human`.`id` = `conferee`.`participant`))) order by `section`.`title` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-04-18 16:29:55
