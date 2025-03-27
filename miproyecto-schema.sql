-- MySQL dump 10.13  Distrib 8.0.41, for Linux (x86_64)
--
-- Host: localhost    Database: mydb
-- ------------------------------------------------------
-- Server version	8.0.41-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `arbitro`
--

DROP TABLE IF EXISTS `arbitro`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `arbitro` (
  `Id_arbitro` int NOT NULL,
  `Nombre_arbitro` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Id_arbitro`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `campo`
--

DROP TABLE IF EXISTS `campo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `campo` (
  `Id_campo` int NOT NULL,
  `Tipo` varchar(45) DEFAULT NULL,
  `Aforo` int DEFAULT NULL,
  `Nombre_campo` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `EQUIPO_Id_equipo` int NOT NULL,
  PRIMARY KEY (`Id_campo`),
  KEY `fk_CAMPO_EQUIPO1_idx` (`EQUIPO_Id_equipo`),
  CONSTRAINT `fk_CAMPO_EQUIPO1` FOREIGN KEY (`EQUIPO_Id_equipo`) REFERENCES `equipo` (`Id_equipo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `equipo`
--

DROP TABLE IF EXISTS `equipo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `equipo` (
  `Id_equipo` int NOT NULL,
  `Nombre_equipo` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `Nombre_estadio` varchar(45) DEFAULT NULL,
  `Anio_fundacion` date DEFAULT NULL,
  `Ciudad` varchar(45) DEFAULT NULL,
  `PRESIDENTE_DNI` int NOT NULL,
  PRIMARY KEY (`Id_equipo`),
  KEY `fk_EQUIPO_PRESIDENTE1_idx` (`PRESIDENTE_DNI`),
  CONSTRAINT `fk_EQUIPO_PRESIDENTE1` FOREIGN KEY (`PRESIDENTE_DNI`) REFERENCES `presidente` (`DNI`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `error_equipo`
--

DROP TABLE IF EXISTS `error_equipo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `error_equipo` (
  `mensaje` varchar(255) DEFAULT NULL,
  `fecha_error` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `error_insert`
--

DROP TABLE IF EXISTS `error_insert`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `error_insert` (
  `mensaje` varchar(255) DEFAULT NULL,
  `fecha_error` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gol`
--

DROP TABLE IF EXISTS `gol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gol` (
  `id_partido` int NOT NULL,
  `id_jugador` int DEFAULT NULL,
  `Minuto` int NOT NULL,
  PRIMARY KEY (`id_partido`,`Minuto`),
  KEY `id_partido` (`id_partido`),
  KEY `GOL_ibfk_2` (`id_jugador`),
  CONSTRAINT `fk_gol_jugador` FOREIGN KEY (`id_jugador`) REFERENCES `jugador` (`id_jugador`),
  CONSTRAINT `fk_gol_partido` FOREIGN KEY (`id_partido`) REFERENCES `partido` (`Id_partido`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`SqlAdminm`@`%`*/ /*!50003 TRIGGER `actualizarGolesPartidoDespuesGol` AFTER INSERT ON `gol` FOR EACH ROW begin
    declare equipo_jugador int;
    declare equipo_local int;
    declare equipo_visitante int;

    select EQUIPO_Id_equipo into equipo_jugador
    from JUGADOR
    where id_jugador = NEW.id_jugador;

    select EQUIPO_Id_equipo_local, EQUIPO_Id_equipo_visitante
    into equipo_local, equipo_visitante
    from PARTIDO
    where Id_partido = NEW.id_partido;

    if equipo_jugador = equipo_local then
        update PARTIDO
        set Goles_casa = Goles_casa + 1
        where Id_partido = NEW.id_partido;
    elseif equipo_jugador = equipo_visitante then
        update PARTIDO
        set Goles_visitante = Goles_visitante + 1
        where Id_partido = NEW.id_partido;
    end if;
end */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `jugador`
--

DROP TABLE IF EXISTS `jugador`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jugador` (
  `id_jugador` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `Apellidos` varchar(45) DEFAULT NULL,
  `Fecha_nacimiento` date DEFAULT NULL,
  `Posicion` varchar(45) DEFAULT NULL,
  `EQUIPO_Id_equipo` int NOT NULL,
  PRIMARY KEY (`id_jugador`),
  KEY `fk_JUGADOR_EQUIPO1_idx` (`EQUIPO_Id_equipo`),
  CONSTRAINT `fk_JUGADOR_EQUIPO1` FOREIGN KEY (`EQUIPO_Id_equipo`) REFERENCES `equipo` (`Id_equipo`)
) ENGINE=InnoDB AUTO_INCREMENT=5002 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`SqlAdminm`@`%`*/ /*!50003 TRIGGER `verificarEdadJugadorAntesInsertar` BEFORE INSERT ON `jugador` FOR EACH ROW begin
    declare edad int;

    
    set edad = TIMESTAMPDIFF(YEAR, new.Fecha_nacimiento, CURDATE());

    
    if edad < 16 then
        
        insert into Error_insert (mensaje, fecha_error)
        values (
            concat('Error: El jugador ', new.Nombre, ' ', new.Apellidos, ' tiene ', edad, ' años y no cumple con la edad mínima de 16 años.'),
            now()
        );

        set new.id_jugador = NULL;
    end if;
end */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `partido`
--

DROP TABLE IF EXISTS `partido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `partido` (
  `Id_partido` int NOT NULL,
  `Fecha_partido` date DEFAULT NULL,
  `Goles_casa` int DEFAULT NULL,
  `Goles_visitante` int DEFAULT NULL,
  `EQUIPO_Id_equipo_local` int NOT NULL,
  `EQUIPO_Id_equipo_visitante` int NOT NULL,
  `ARBITRO_Id_arbitro` int DEFAULT NULL,
  `CAMPO_Id_campo` int NOT NULL,
  PRIMARY KEY (`Id_partido`),
  KEY `fk_PARTIDO_EQUIPO1_idx` (`EQUIPO_Id_equipo_local`),
  KEY `fk_PARTIDO_EQUIPO2_idx` (`EQUIPO_Id_equipo_visitante`),
  KEY `fk_PARTIDO_ARBITRO1_idx` (`ARBITRO_Id_arbitro`),
  KEY `fk_PARTIDO_CAMPO1_idx` (`CAMPO_Id_campo`),
  CONSTRAINT `fk_PARTIDO_ARBITRO1` FOREIGN KEY (`ARBITRO_Id_arbitro`) REFERENCES `arbitro` (`Id_arbitro`),
  CONSTRAINT `fk_PARTIDO_CAMPO1` FOREIGN KEY (`CAMPO_Id_campo`) REFERENCES `campo` (`Id_campo`),
  CONSTRAINT `fk_PARTIDO_EQUIPO1` FOREIGN KEY (`EQUIPO_Id_equipo_local`) REFERENCES `equipo` (`Id_equipo`),
  CONSTRAINT `fk_PARTIDO_EQUIPO2` FOREIGN KEY (`EQUIPO_Id_equipo_visitante`) REFERENCES `equipo` (`Id_equipo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `presidente`
--

DROP TABLE IF EXISTS `presidente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `presidente` (
  `DNI` int NOT NULL,
  `Nombre_presi` varchar(45) DEFAULT NULL,
  `Apellidos_presi` varchar(45) DEFAULT NULL,
  `Fecha_nacimiento` date DEFAULT NULL,
  `Anio_fundacion` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`DNI`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `vista_Campos_Promedio_Goles_Superior`
--

DROP TABLE IF EXISTS `vista_Campos_Promedio_Goles_Superior`;
/*!50001 DROP VIEW IF EXISTS `vista_Campos_Promedio_Goles_Superior`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vista_Campos_Promedio_Goles_Superior` AS SELECT 
 1 AS `Nombre_campo`,
 1 AS `promedio_goles`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vista_Equipo_Goles`
--

DROP TABLE IF EXISTS `vista_Equipo_Goles`;
/*!50001 DROP VIEW IF EXISTS `vista_Equipo_Goles`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vista_Equipo_Goles` AS SELECT 
 1 AS `Nombre_equipo`,
 1 AS `Nombre_presi`,
 1 AS `total_goles`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vista_Campos_Promedio_Goles_Superior`
--

/*!50001 DROP VIEW IF EXISTS `vista_Campos_Promedio_Goles_Superior`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`proyectobd`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vista_Campos_Promedio_Goles_Superior` AS select `c`.`Nombre_campo` AS `Nombre_campo`,avg((`p`.`Goles_casa` + `p`.`Goles_visitante`)) AS `promedio_goles` from (`campo` `c` join `partido` `p` on((`c`.`Id_campo` = `p`.`CAMPO_Id_campo`))) group by `c`.`Nombre_campo` having (avg((`p`.`Goles_casa` + `p`.`Goles_visitante`)) > (select avg((`p`.`Goles_casa` + `p`.`Goles_visitante`)) from `partido` `p`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vista_Equipo_Goles`
--

/*!50001 DROP VIEW IF EXISTS `vista_Equipo_Goles`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`proyectobd`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vista_Equipo_Goles` AS select `e`.`Nombre_equipo` AS `Nombre_equipo`,`p`.`Nombre_presi` AS `Nombre_presi`,coalesce(sum((`pa`.`Goles_casa` + `pa`.`Goles_visitante`)),0) AS `total_goles` from (((`equipo` `e` left join `presidente` `p` on((`e`.`PRESIDENTE_DNI` = `p`.`DNI`))) left join `partido` `pa` on(((`e`.`Id_equipo` = `pa`.`EQUIPO_Id_equipo_local`) or (`e`.`Id_equipo` = `pa`.`EQUIPO_Id_equipo_visitante`)))) left join `gol` `g` on(((`pa`.`Id_partido` = `g`.`id_partido`) and `g`.`id_jugador` in (select `j`.`id_jugador` from `jugador` `j` where (`j`.`EQUIPO_Id_equipo` = `e`.`Id_equipo`))))) group by `e`.`Nombre_equipo`,`p`.`Nombre_presi` */;
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

-- Dump completed on 2025-03-26 14:40:55
