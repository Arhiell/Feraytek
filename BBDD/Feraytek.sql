CREATE DATABASE  IF NOT EXISTS `feraytek` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `feraytek`;
-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: localhost    Database: feraytek
-- ------------------------------------------------------
-- Server version	8.0.42

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `administradores`
--

DROP TABLE IF EXISTS `administradores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `administradores` (
  `id_admin` int unsigned NOT NULL AUTO_INCREMENT,
  `id_usuario` int unsigned NOT NULL,
  `dni` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellido` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono` varchar(25) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cargo` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_admin`),
  UNIQUE KEY `id_usuario` (`id_usuario`),
  UNIQUE KEY `dni` (`dni`),
  CONSTRAINT `fk_admins_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_admins_dni` CHECK ((`dni` <> _utf8mb4''))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `administradores`
--

LOCK TABLES `administradores` WRITE;
/*!40000 ALTER TABLE `administradores` DISABLE KEYS */;
/*!40000 ALTER TABLE `administradores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `carrito`
--

DROP TABLE IF EXISTS `carrito`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `carrito` (
  `id_carrito` int unsigned NOT NULL AUTO_INCREMENT,
  `id_usuario` int unsigned NOT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` enum('activo','comprado','cancelado') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'activo',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_carrito`),
  KEY `idx_carrito_usuario_estado` (`id_usuario`,`estado`),
  KEY `idx_carrito_user` (`id_usuario`),
  CONSTRAINT `fk_carrito_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carrito`
--

LOCK TABLES `carrito` WRITE;
/*!40000 ALTER TABLE `carrito` DISABLE KEYS */;
/*!40000 ALTER TABLE `carrito` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `carrito_detalle`
--

DROP TABLE IF EXISTS `carrito_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `carrito_detalle` (
  `id_detalle` int unsigned NOT NULL AUTO_INCREMENT,
  `id_carrito` int unsigned NOT NULL,
  `id_producto` int unsigned NOT NULL,
  `id_variante` int unsigned DEFAULT NULL,
  `cantidad` int unsigned NOT NULL DEFAULT '1',
  `precio_unitario` decimal(12,2) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_detalle`),
  UNIQUE KEY `uq_cd_unique_line` (`id_carrito`,`id_producto`,`id_variante`),
  KEY `fk_cd_producto` (`id_producto`),
  KEY `fk_cd_variante` (`id_variante`),
  CONSTRAINT `fk_cd_carrito` FOREIGN KEY (`id_carrito`) REFERENCES `carrito` (`id_carrito`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cd_producto` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_cd_variante` FOREIGN KEY (`id_variante`) REFERENCES `variantes_producto` (`id_variante`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_cd_cantidad_pos` CHECK ((`cantidad` > 0)),
  CONSTRAINT `chk_cd_precio_nonneg` CHECK ((`precio_unitario` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carrito_detalle`
--

LOCK TABLES `carrito_detalle` WRITE;
/*!40000 ALTER TABLE `carrito_detalle` DISABLE KEYS */;
/*!40000 ALTER TABLE `carrito_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categorias`
--

DROP TABLE IF EXISTS `categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categorias` (
  `id_categoria` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre_categoria` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` enum('activa','inactiva') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'activa',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `nombre_categoria` (`nombre_categoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias`
--

LOCK TABLES `categorias` WRITE;
/*!40000 ALTER TABLE `categorias` DISABLE KEYS */;
/*!40000 ALTER TABLE `categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clientes`
--

DROP TABLE IF EXISTS `clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clientes` (
  `id_cliente` int unsigned NOT NULL AUTO_INCREMENT,
  `id_usuario` int unsigned NOT NULL,
  `dni` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellido` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono` varchar(25) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `direccion` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ciudad` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `provincia` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `pais` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Argentina',
  `codigo_postal` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_cliente`),
  UNIQUE KEY `id_usuario` (`id_usuario`),
  UNIQUE KEY `dni` (`dni`),
  CONSTRAINT `fk_clientes_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_clientes_dni` CHECK ((`dni` <> _utf8mb4''))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
/*!40000 ALTER TABLE `clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `descuentos`
--

DROP TABLE IF EXISTS `descuentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `descuentos` (
  `id_descuento` int unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tipo` enum('porcentaje','monto','envio_gratis') COLLATE utf8mb4_unicode_ci NOT NULL,
  `valor` decimal(12,2) NOT NULL DEFAULT '0.00',
  `fecha_inicio` datetime NOT NULL,
  `fecha_fin` datetime NOT NULL,
  `estado` enum('activo','inactivo') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'activo',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_descuento`),
  UNIQUE KEY `codigo` (`codigo`),
  CONSTRAINT `chk_desc_fechas` CHECK ((`fecha_fin` > `fecha_inicio`)),
  CONSTRAINT `chk_desc_valor_nonneg` CHECK ((`valor` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `descuentos`
--

LOCK TABLES `descuentos` WRITE;
/*!40000 ALTER TABLE `descuentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `descuentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `envios`
--

DROP TABLE IF EXISTS `envios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `envios` (
  `id_envio` int unsigned NOT NULL AUTO_INCREMENT,
  `id_pedido` int unsigned NOT NULL,
  `destinatario` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `direccion_envio` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ciudad` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `provincia` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `pais` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Argentina',
  `codigo_postal` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `empresa_envio` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `numero_seguimiento` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado_envio` enum('preparando','en_camino','entregado','devuelto') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'preparando',
  `fecha_envio` datetime DEFAULT NULL,
  `fecha_entrega` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_envio`),
  UNIQUE KEY `id_pedido` (`id_pedido`),
  KEY `idx_envios_estado` (`estado_envio`),
  CONSTRAINT `fk_envios_pedido` FOREIGN KEY (`id_pedido`) REFERENCES `pedidos` (`id_pedido`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `envios`
--

LOCK TABLES `envios` WRITE;
/*!40000 ALTER TABLE `envios` DISABLE KEYS */;
/*!40000 ALTER TABLE `envios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `imagenes_productos`
--

DROP TABLE IF EXISTS `imagenes_productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `imagenes_productos` (
  `id_imagen` int unsigned NOT NULL AUTO_INCREMENT,
  `id_producto` int unsigned NOT NULL,
  `id_variante` int unsigned DEFAULT NULL,
  `url_imagen` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `posicion` int unsigned NOT NULL DEFAULT '1',
  `alt_text` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_imagen`),
  UNIQUE KEY `uq_imagen_prod_var_url` (`id_producto`,`id_variante`,`url_imagen`),
  KEY `fk_img_variante` (`id_variante`),
  KEY `idx_imagenes_prod_pos` (`id_producto`,`posicion`),
  CONSTRAINT `fk_img_producto` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_img_variante` FOREIGN KEY (`id_variante`) REFERENCES `variantes_producto` (`id_variante`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `imagenes_productos`
--

LOCK TABLES `imagenes_productos` WRITE;
/*!40000 ALTER TABLE `imagenes_productos` DISABLE KEYS */;
/*!40000 ALTER TABLE `imagenes_productos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `logs`
--

DROP TABLE IF EXISTS `logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `logs` (
  `id_log` bigint unsigned NOT NULL AUTO_INCREMENT,
  `id_usuario` int unsigned DEFAULT NULL,
  `accion` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_hora` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ip` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_log`),
  KEY `fk_logs_usuario` (`id_usuario`),
  CONSTRAINT `fk_logs_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logs`
--

LOCK TABLES `logs` WRITE;
/*!40000 ALTER TABLE `logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pagos`
--

DROP TABLE IF EXISTS `pagos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pagos` (
  `id_pago` int unsigned NOT NULL AUTO_INCREMENT,
  `id_pedido` int unsigned NOT NULL,
  `metodo_pago` enum('mercado_pago','transferencia','tarjeta','otros') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'mercado_pago',
  `estado_pago` enum('pendiente','aprobado','rechazado') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pendiente',
  `id_transaccion` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `monto` decimal(12,2) NOT NULL,
  `fecha_pago` datetime DEFAULT NULL,
  `raw_gateway_json` json DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_pago`),
  UNIQUE KEY `id_pedido` (`id_pedido`),
  UNIQUE KEY `id_transaccion` (`id_transaccion`),
  CONSTRAINT `fk_pagos_pedido` FOREIGN KEY (`id_pedido`) REFERENCES `pedidos` (`id_pedido`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_pago_monto_nonneg` CHECK ((`monto` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pagos`
--

LOCK TABLES `pagos` WRITE;
/*!40000 ALTER TABLE `pagos` DISABLE KEYS */;
/*!40000 ALTER TABLE `pagos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedido_detalle`
--

DROP TABLE IF EXISTS `pedido_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedido_detalle` (
  `id_detalle` int unsigned NOT NULL AUTO_INCREMENT,
  `id_pedido` int unsigned NOT NULL,
  `id_producto` int unsigned NOT NULL,
  `id_variante` int unsigned DEFAULT NULL,
  `cantidad` int unsigned NOT NULL,
  `precio_unitario` decimal(12,2) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_detalle`),
  UNIQUE KEY `uq_pd_unique_line` (`id_pedido`,`id_producto`,(coalesce(`id_variante`,0))),
  KEY `fk_pd_producto` (`id_producto`),
  KEY `fk_pd_variante` (`id_variante`),
  KEY `idx_pd_pedido` (`id_pedido`),
  CONSTRAINT `fk_pd_pedido` FOREIGN KEY (`id_pedido`) REFERENCES `pedidos` (`id_pedido`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pd_producto` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_pd_variante` FOREIGN KEY (`id_variante`) REFERENCES `variantes_producto` (`id_variante`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_pd_cantidad_pos` CHECK ((`cantidad` > 0)),
  CONSTRAINT `chk_pd_precio_nonneg` CHECK ((`precio_unitario` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedido_detalle`
--

LOCK TABLES `pedido_detalle` WRITE;
/*!40000 ALTER TABLE `pedido_detalle` DISABLE KEYS */;
/*!40000 ALTER TABLE `pedido_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedidos`
--

DROP TABLE IF EXISTS `pedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedidos` (
  `id_pedido` int unsigned NOT NULL AUTO_INCREMENT,
  `id_usuario` int unsigned NOT NULL,
  `fecha_pedido` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `subtotal` decimal(12,2) NOT NULL DEFAULT '0.00',
  `descuento_total` decimal(12,2) NOT NULL DEFAULT '0.00',
  `costo_envio` decimal(12,2) NOT NULL DEFAULT '0.00',
  `total` decimal(12,2) NOT NULL,
  `estado` enum('pendiente','pagado','enviado','entregado','cancelado','reembolsado') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pendiente',
  `metodo_entrega` enum('retiro','envio_domicilio') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'envio_domicilio',
  `fecha_estimada_entrega` date DEFAULT NULL,
  `notas` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_pedido`),
  KEY `idx_pedidos_user_fecha` (`id_usuario`,`fecha_pedido`),
  CONSTRAINT `fk_pedidos_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_descuento_nonneg` CHECK ((`descuento_total` >= 0)),
  CONSTRAINT `chk_envio_nonneg` CHECK ((`costo_envio` >= 0)),
  CONSTRAINT `chk_total_nonneg` CHECK ((`total` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedidos`
--

LOCK TABLES `pedidos` WRITE;
/*!40000 ALTER TABLE `pedidos` DISABLE KEYS */;
/*!40000 ALTER TABLE `pedidos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedidos_descuentos`
--

DROP TABLE IF EXISTS `pedidos_descuentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedidos_descuentos` (
  `id_pedido` int unsigned NOT NULL,
  `id_descuento` int unsigned NOT NULL,
  `monto_aplicado` decimal(12,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id_pedido`,`id_descuento`),
  KEY `fk_pdsc_desc` (`id_descuento`),
  CONSTRAINT `fk_pdsc_desc` FOREIGN KEY (`id_descuento`) REFERENCES `descuentos` (`id_descuento`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_pdsc_pedido` FOREIGN KEY (`id_pedido`) REFERENCES `pedidos` (`id_pedido`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedidos_descuentos`
--

LOCK TABLES `pedidos_descuentos` WRITE;
/*!40000 ALTER TABLE `pedidos_descuentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `pedidos_descuentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productos`
--

DROP TABLE IF EXISTS `productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productos` (
  `id_producto` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `precio_base` decimal(12,2) NOT NULL,
  `stock` int unsigned NOT NULL DEFAULT '0',
  `id_categoria` int unsigned NOT NULL,
  `estado` enum('activo','inactivo','descontinuado') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'activo',
  `fecha_alta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_producto`),
  KEY `fk_productos_categoria` (`id_categoria`),
  KEY `idx_prod_nombre` (`nombre`),
  CONSTRAINT `fk_productos_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_precio_base_nonneg` CHECK ((`precio_base` >= 0)),
  CONSTRAINT `chk_stock_nonneg` CHECK ((`stock` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productos`
--

LOCK TABLES `productos` WRITE;
/*!40000 ALTER TABLE `productos` DISABLE KEYS */;
/*!40000 ALTER TABLE `productos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productos_categorias`
--

DROP TABLE IF EXISTS `productos_categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productos_categorias` (
  `id_producto` int unsigned NOT NULL,
  `id_categoria` int unsigned NOT NULL,
  PRIMARY KEY (`id_producto`,`id_categoria`),
  KEY `fk_pc_categoria` (`id_categoria`),
  CONSTRAINT `fk_pc_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pc_producto` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productos_categorias`
--

LOCK TABLES `productos_categorias` WRITE;
/*!40000 ALTER TABLE `productos_categorias` DISABLE KEYS */;
/*!40000 ALTER TABLE `productos_categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reseñas`
--

DROP TABLE IF EXISTS `reseñas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reseñas` (
  `id_reseña` int unsigned NOT NULL AUTO_INCREMENT,
  `id_producto` int unsigned NOT NULL,
  `id_usuario` int unsigned NOT NULL,
  `calificacion` tinyint unsigned NOT NULL,
  `comentario` text COLLATE utf8mb4_unicode_ci,
  `fecha_reseña` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_reseña`),
  UNIQUE KEY `uq_resena_prod_user` (`id_producto`,`id_usuario`),
  KEY `fk_rev_usuario` (`id_usuario`),
  CONSTRAINT `fk_rev_producto` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_rev_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_calif_range` CHECK ((`calificacion` between 1 and 5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reseñas`
--

LOCK TABLES `reseñas` WRITE;
/*!40000 ALTER TABLE `reseñas` DISABLE KEYS */;
/*!40000 ALTER TABLE `reseñas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `soporte`
--

DROP TABLE IF EXISTS `soporte`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `soporte` (
  `id_soporte` int unsigned NOT NULL AUTO_INCREMENT,
  `id_usuario` int unsigned NOT NULL,
  `asunto` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mensaje` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `canal` enum('email','whatsapp','web') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'web',
  `estado` enum('pendiente','respondido','cerrado') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pendiente',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `respuesta` text COLLATE utf8mb4_unicode_ci,
  `fecha_respuesta` datetime DEFAULT NULL,
  PRIMARY KEY (`id_soporte`),
  KEY `fk_soporte_usuario` (`id_usuario`),
  KEY `idx_soporte_estado` (`estado`),
  CONSTRAINT `fk_soporte_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `soporte`
--

LOCK TABLES `soporte` WRITE;
/*!40000 ALTER TABLE `soporte` DISABLE KEYS */;
/*!40000 ALTER TABLE `soporte` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id_usuario` int unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rol` enum('cliente','admin') COLLATE utf8mb4_unicode_ci NOT NULL,
  `estado` enum('activo','inactivo') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'activo',
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ultimo_login` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `variantes_producto`
--

DROP TABLE IF EXISTS `variantes_producto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `variantes_producto` (
  `id_variante` int unsigned NOT NULL AUTO_INCREMENT,
  `id_producto` int unsigned NOT NULL,
  `atributo` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `valor` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `precio` decimal(12,2) DEFAULT NULL,
  `stock` int unsigned NOT NULL DEFAULT '0',
  `sku` varchar(60) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_variante`),
  UNIQUE KEY `sku` (`sku`),
  KEY `idx_var_prod_attr_val` (`id_producto`,`atributo`,`valor`),
  CONSTRAINT `fk_var_producto` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_var_precio_nonneg` CHECK (((`precio` is null) or (`precio` >= 0))),
  CONSTRAINT `chk_var_stock_nonneg` CHECK ((`stock` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `variantes_producto`
--

LOCK TABLES `variantes_producto` WRITE;
/*!40000 ALTER TABLE `variantes_producto` DISABLE KEYS */;
/*!40000 ALTER TABLE `variantes_producto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'feraytek'
--

--
-- Dumping routines for database 'feraytek'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-08-29  8:36:02
