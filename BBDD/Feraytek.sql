-- ======================================================================
-- E-COMMERCE (Feraytek) - Esquema completo MySQL 8+
-- ======================================================================


CREATE DATABASE IF NOT EXISTS feraytek
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;
USE feraytek;


-- ======================================================================
-- 1) USUARIOS (login común) + PERFILES (clientes / administradores)
-- ======================================================================

CREATE TABLE usuarios (
  id_usuario       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email            VARCHAR(150) NOT NULL UNIQUE,
  password_hash    VARCHAR(255) NOT NULL,           -- bcrypt/argon2
  rol              ENUM('cliente','admin') NOT NULL,
  estado           ENUM('activo','inactivo') NOT NULL DEFAULT 'activo',
  fecha_registro   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ultimo_login     DATETIME NULL,
  -- Para auditoría mínima sin ir a logs:
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Perfil CLIENTE (datos personales y de envío)
CREATE TABLE clientes (
  id_cliente       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_usuario       INT UNSIGNED NOT NULL UNIQUE,
  dni              VARCHAR(20) NOT NULL UNIQUE,      -- DNI argentino; usar VARCHAR por si hay prefijos
  nombre           VARCHAR(100) NOT NULL,
  apellido         VARCHAR(100) NOT NULL,
  telefono         VARCHAR(25) NULL,
  direccion        VARCHAR(255) NOT NULL,
  ciudad           VARCHAR(100) NOT NULL,
  provincia        VARCHAR(100) NOT NULL,
  pais             VARCHAR(100) NOT NULL DEFAULT 'Argentina',
  codigo_postal    VARCHAR(20) NOT NULL,
  fecha_nacimiento DATE NULL,
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_clientes_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_clientes_dni CHECK (dni <> '')
) ENGINE=InnoDB;

-- Perfil ADMINISTRADOR (datos del staff)
CREATE TABLE administradores (
  id_admin         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_usuario       INT UNSIGNED NOT NULL UNIQUE,
  dni              VARCHAR(20) NOT NULL UNIQUE,
  nombre           VARCHAR(100) NOT NULL,
  apellido         VARCHAR(100) NOT NULL,
  telefono         VARCHAR(25) NULL,
  cargo            VARCHAR(100) NOT NULL,            -- p.ej. "encargado", "vendedor", "superadmin"
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_admins_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_admins_dni CHECK (dni <> '')
) ENGINE=InnoDB;

-- ======================================================================
-- 2) CATALOGO (categorías, productos, variantes, imágenes)
-- ======================================================================

CREATE TABLE categorias (
  id_categoria     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre_categoria VARCHAR(120) NOT NULL UNIQUE,
  descripcion      VARCHAR(300) NULL,
  estado           ENUM('activa','inactiva') NOT NULL DEFAULT 'activa',
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE productos (
  id_producto      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre           VARCHAR(200) NOT NULL,
  descripcion      TEXT NULL,
  precio_base      DECIMAL(12,2) NOT NULL,
  stock            INT UNSIGNED NOT NULL DEFAULT 0,
  id_categoria     INT UNSIGNED NOT NULL,            -- categoría principal
  estado           ENUM('activo','inactivo','descontinuado') NOT NULL DEFAULT 'activo',
  fecha_alta       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_productos_categoria
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_precio_base_nonneg CHECK (precio_base >= 0),
  CONSTRAINT chk_stock_nonneg CHECK (stock >= 0)
) ENGINE=InnoDB;

-- Muchos-a-muchos: un producto puede estar en varias categorías
CREATE TABLE productos_categorias (
  id_producto      INT UNSIGNED NOT NULL,
  id_categoria     INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_producto, id_categoria),
  CONSTRAINT fk_pc_producto
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pc_categoria
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Variantes (RAM, color, almacenamiento, procesador, etc.)
CREATE TABLE variantes_producto (
  id_variante      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_producto      INT UNSIGNED NOT NULL,
  atributo         VARCHAR(80)  NOT NULL,            -- ej: "RAM", "Color", "Almacenamiento"
  valor            VARCHAR(120) NOT NULL,            -- ej: "16GB", "Negro", "512GB"
  precio           DECIMAL(12,2) NULL,               -- si es NULL, usar precio_base
  stock            INT UNSIGNED NOT NULL DEFAULT 0,
  sku              VARCHAR(60) NULL UNIQUE,          -- opcional, útil para logística
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_var_producto
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_var_stock_nonneg CHECK (stock >= 0),
  CONSTRAINT chk_var_precio_nonneg CHECK (precio IS NULL OR precio >= 0)
) ENGINE=InnoDB;

-- Imágenes múltiples por producto/variante
CREATE TABLE imagenes_productos (
  id_imagen        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_producto      INT UNSIGNED NOT NULL,
  id_variante      INT UNSIGNED NULL,
  url_imagen       VARCHAR(500) NOT NULL,
  posicion         INT UNSIGNED NOT NULL DEFAULT 1,  -- orden de galería
  alt_text         VARCHAR(200) NULL,                -- accesibilidad/SEO
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_img_producto
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_img_variante
    FOREIGN KEY (id_variante) REFERENCES variantes_producto(id_variante)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_imagenes_prod_pos ON imagenes_productos(id_producto, posicion);
CREATE UNIQUE INDEX uq_imagen_prod_var_url ON imagenes_productos(id_producto, id_variante, url_imagen);

-- ======================================================================
-- 3) CARRITO (1 activo por usuario) + DETALLE
-- ======================================================================

CREATE TABLE carrito (
  id_carrito       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_usuario       INT UNSIGNED NOT NULL,
  fecha_creacion   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  estado           ENUM('activo','comprado','cancelado') NOT NULL DEFAULT 'activo',
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_carrito_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- NOTA: MySQL no soporta índices filtrados; para "1 carrito activo por usuario"
-- aplicá lógica en la app o un TRIGGER. Como ayuda, este índice acelera búsquedas:
CREATE INDEX idx_carrito_usuario_estado ON carrito(id_usuario, estado);

CREATE TABLE carrito_detalle (
  id_detalle       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_carrito       INT UNSIGNED NOT NULL,
  id_producto      INT UNSIGNED NOT NULL,
  id_variante      INT UNSIGNED NULL,
  cantidad         INT UNSIGNED NOT NULL DEFAULT 1,
  precio_unitario  DECIMAL(12,2) NOT NULL,
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_cd_carrito
    FOREIGN KEY (id_carrito) REFERENCES carrito(id_carrito)
    ON DELETE CASCADE ON UPDATE CASCADE,

  CONSTRAINT fk_cd_producto
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
    ON DELETE RESTRICT ON UPDATE CASCADE,

  CONSTRAINT fk_cd_variante
    FOREIGN KEY (id_variante) REFERENCES variantes_producto(id_variante)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT chk_cd_cantidad_pos CHECK (cantidad > 0),
  CONSTRAINT chk_cd_precio_nonneg CHECK (precio_unitario >= 0),

  -- Evita duplicados: producto + variante dentro del mismo carrito
  UNIQUE KEY uq_cd_unique_line (id_carrito, id_producto, id_variante)
) ENGINE=InnoDB;

-- ======================================================================
-- 4) PEDIDOS + DETALLE + PAGOS + ENVIOS
-- ======================================================================

CREATE TABLE pedidos (
  id_pedido              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_usuario             INT UNSIGNED NOT NULL,
  fecha_pedido           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  subtotal               DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  descuento_total        DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  costo_envio            DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  total                  DECIMAL(12,2) NOT NULL,            -- subtotal - descuentos + envío
  estado                 ENUM('pendiente','pagado','enviado','entregado','cancelado','reembolsado') NOT NULL DEFAULT 'pendiente',
  metodo_entrega         ENUM('retiro','envio_domicilio') NOT NULL DEFAULT 'envio_domicilio',
  fecha_estimada_entrega DATE NULL,
  notas                  VARCHAR(500) NULL,
  created_at             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_pedidos_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_total_nonneg CHECK (total >= 0),
  CONSTRAINT chk_descuento_nonneg CHECK (descuento_total >= 0),
  CONSTRAINT chk_envio_nonneg CHECK (costo_envio >= 0)
) ENGINE=InnoDB;

CREATE TABLE pedido_detalle (
  id_detalle       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_pedido        INT UNSIGNED NOT NULL,
  id_producto      INT UNSIGNED NOT NULL,
  id_variante      INT UNSIGNED NULL,
  cantidad         INT UNSIGNED NOT NULL,
  precio_unitario  DECIMAL(12,2) NOT NULL,
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  -- Relaciones
  CONSTRAINT fk_pd_pedido
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
    ON DELETE CASCADE ON UPDATE CASCADE,

  CONSTRAINT fk_pd_producto
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
    ON DELETE RESTRICT ON UPDATE CASCADE,

  CONSTRAINT fk_pd_variante
    FOREIGN KEY (id_variante) REFERENCES variantes_producto(id_variante)
    ON DELETE SET NULL ON UPDATE CASCADE,

  -- Checks
  CONSTRAINT chk_pd_cantidad_pos CHECK (cantidad > 0),
  CONSTRAINT chk_pd_precio_nonneg CHECK (precio_unitario >= 0)
) ENGINE=InnoDB;

-- Índices
CREATE INDEX idx_pd_pedido ON pedido_detalle(id_pedido);

-- ÍNDICE ÚNICO: usar COALESCE directamente (MySQL 8.0.13+)
CREATE UNIQUE INDEX uq_pd_unique_line
ON pedido_detalle (id_pedido, id_producto, (COALESCE(id_variante,0)));




CREATE TABLE pagos (
  id_pago          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_pedido        INT UNSIGNED NOT NULL UNIQUE,     -- 1 pago final por pedido (ajusta si querés múltiples)
  metodo_pago      ENUM('mercado_pago','transferencia','tarjeta','otros') NOT NULL DEFAULT 'mercado_pago',
  estado_pago      ENUM('pendiente','aprobado','rechazado') NOT NULL DEFAULT 'pendiente',
  id_transaccion   VARCHAR(120) NULL UNIQUE,         -- ID de MP u otro gateway
  monto            DECIMAL(12,2) NOT NULL,
  fecha_pago       DATETIME NULL,
  raw_gateway_json JSON NULL,                        -- respuesta completa del gateway (opcional)
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_pagos_pedido
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_pago_monto_nonneg CHECK (monto >= 0)
) ENGINE=InnoDB;

CREATE TABLE envios (
  id_envio          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_pedido         INT UNSIGNED NOT NULL UNIQUE,    -- 1 registro de envío por pedido
  destinatario      VARCHAR(200) NULL,               -- opcional si difiere del cliente
  direccion_envio   VARCHAR(255) NOT NULL,
  ciudad            VARCHAR(100) NOT NULL,
  provincia         VARCHAR(100) NOT NULL,
  pais              VARCHAR(100) NOT NULL DEFAULT 'Argentina',
  codigo_postal     VARCHAR(20) NOT NULL,
  empresa_envio     VARCHAR(120) NULL,               -- p.ej. "Andreani"
  numero_seguimiento VARCHAR(120) NULL,
  estado_envio      ENUM('preparando','en_camino','entregado','devuelto') NOT NULL DEFAULT 'preparando',
  fecha_envio       DATETIME NULL,
  fecha_entrega     DATETIME NULL,
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_envios_pedido
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ======================================================================
-- 5) RESEÑAS, DESCUENTOS, SOPORTE, LOGS
-- ======================================================================

CREATE TABLE reseñas (
  id_reseña        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_producto      INT UNSIGNED NOT NULL,
  id_usuario       INT UNSIGNED NOT NULL,            -- quien dejó la reseña
  calificacion     TINYINT UNSIGNED NOT NULL,        -- 1..5
  comentario       TEXT NULL,
  fecha_reseña     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_rev_producto
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_rev_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_calif_range CHECK (calificacion BETWEEN 1 AND 5)
) ENGINE=InnoDB;

-- 1 reseña por usuario por producto
CREATE UNIQUE INDEX uq_resena_prod_user ON reseñas(id_producto, id_usuario);

CREATE TABLE descuentos (
  id_descuento     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  codigo           VARCHAR(60) NOT NULL UNIQUE,
  descripcion      VARCHAR(255) NULL,
  tipo             ENUM('porcentaje','monto','envio_gratis') NOT NULL,
  valor            DECIMAL(12,2) NOT NULL DEFAULT 0.00,  -- porcentaje o monto
  fecha_inicio     DATETIME NOT NULL,
  fecha_fin        DATETIME NOT NULL,
  estado           ENUM('activo','inactivo') NOT NULL DEFAULT 'activo',
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT chk_desc_valor_nonneg CHECK (valor >= 0),
  CONSTRAINT chk_desc_fechas CHECK (fecha_fin > fecha_inicio)
) ENGINE=InnoDB;

-- Relación de cupones con pedidos (si querés guardar qué cupón se aplicó)
CREATE TABLE pedidos_descuentos (
  id_pedido        INT UNSIGNED NOT NULL,
  id_descuento     INT UNSIGNED NOT NULL,
  monto_aplicado   DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (id_pedido, id_descuento),
  CONSTRAINT fk_pdsc_pedido
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pdsc_desc
    FOREIGN KEY (id_descuento) REFERENCES descuentos(id_descuento)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE soporte (
  id_soporte       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_usuario       INT UNSIGNED NOT NULL,
  asunto           VARCHAR(200) NOT NULL,
  mensaje          TEXT NOT NULL,
  canal            ENUM('email','whatsapp','web') NOT NULL DEFAULT 'web',
  estado           ENUM('pendiente','respondido','cerrado') NOT NULL DEFAULT 'pendiente',
  fecha_creacion   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  respuesta        TEXT NULL,
  fecha_respuesta  DATETIME NULL,
  CONSTRAINT fk_soporte_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE logs (
  id_log           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_usuario       INT UNSIGNED NULL,                -- puede ser NULL si es acción del sistema
  accion           VARCHAR(255) NOT NULL,            -- ej: "Login", "Editó producto 15", etc.
  fecha_hora       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ip               VARCHAR(45) NULL,                 -- IPv4/IPv6
  user_agent       VARCHAR(255) NULL,
  CONSTRAINT fk_logs_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE historial_pedidos (
  id_historial INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT UNSIGNED NOT NULL,
  estado_anterior ENUM('pendiente','pagado','enviado','entregado','cancelado','reembolsado'),
  estado_nuevo ENUM('pendiente','pagado','enviado','entregado','cancelado','reembolsado'),
  fecha_cambio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_usuario INT UNSIGNED NULL,
  FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
  FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);


-- ======================================================================
-- INDICES ÚTILES ADICIONALES
-- ======================================================================

CREATE INDEX idx_prod_nombre ON productos(nombre);
CREATE INDEX idx_var_prod_attr_val ON variantes_producto(id_producto, atributo, valor);
CREATE INDEX idx_carrito_user ON carrito(id_usuario);
CREATE INDEX idx_pedidos_user_fecha ON pedidos(id_usuario, fecha_pedido);
CREATE INDEX idx_envios_estado ON envios(estado_envio);
CREATE INDEX idx_soporte_estado ON soporte(estado);
**