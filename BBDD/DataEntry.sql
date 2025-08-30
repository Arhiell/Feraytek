-- ===============================
-- DATOS DE PRUEBA - E-COMMERCE
-- ===============================
USE feraytek;
-- USUARIOS
INSERT INTO usuarios (email, password_hash, rol, estado)
VALUES
  ('juanperez@gmail.com',  '$2y$10$abcdef...', 'cliente', 'activo'),
  ('mariaadmin@gmail.com', '$2y$10$ghijklm...', 'admin',   'activo');

-- CLIENTES
INSERT INTO clientes (id_usuario, dni, nombre, apellido, telefono, direccion, ciudad, provincia, pais, codigo_postal, fecha_nacimiento)
VALUES
  (1, '30111222', 'Juan', 'Pérez', '1122334455', 'Calle Falsa 123', 'Buenos Aires', 'Buenos Aires', 'Argentina', '1000', '1990-05-20');

-- ADMINISTRADORES
INSERT INTO administradores (id_usuario, dni, nombre, apellido, telefono, cargo)
VALUES
  (2, '20222333', 'María', 'Gómez', '1199988877', 'superadmin');

-- CATEGORÍAS
INSERT INTO categorias (nombre_categoria, descripcion)
VALUES
  ('Notebooks', 'Portátiles de todas las marcas'),
  ('Celulares', 'Smartphones y accesorios');

-- PRODUCTOS
INSERT INTO productos (nombre, descripcion, precio_base, stock, id_categoria, estado)
VALUES
  ('Notebook Lenovo IdeaPad 3', 'Notebook 15" Ryzen 5, 8GB RAM, 256GB SSD', 350000, 10, 1, 'activo'),
  ('Samsung Galaxy S23', 'Celular Samsung gama alta 256GB', 500000, 20, 2, 'activo');

-- VARIANTES DE PRODUCTO
INSERT INTO variantes_producto (id_producto, atributo, valor, precio, stock, sku)
VALUES
  (1, 'RAM', '16GB', 380000, 5, 'NB-LEN-16GB'),
  (2, 'Color', 'Negro', NULL, 15, 'S23-BLACK');

-- IMÁGENES DE PRODUCTO
INSERT INTO imagenes_productos (id_producto, id_variante, url_imagen, posicion, alt_text)
VALUES
  (1, NULL, 'https://example.com/lenovo.jpg', 1, 'Lenovo IdeaPad 3'),
  (2, NULL, 'https://example.com/s23.jpg', 1, 'Samsung Galaxy S23');

-- CARRITO
INSERT INTO carrito (id_usuario, estado)
VALUES
  (1, 'activo');

-- CARRITO DETALLE
INSERT INTO carrito_detalle (id_carrito, id_producto, id_variante, cantidad, precio_unitario)
VALUES
  (1, 1, 1, 1, 380000),
  (1, 2, NULL, 2, 500000);

-- PEDIDOS
INSERT INTO pedidos (id_usuario, subtotal, descuento_total, costo_envio, total, estado, metodo_entrega)
VALUES
  (1, 1380000, 0, 5000, 1385000, 'pendiente', 'envio_domicilio');

-- PEDIDO DETALLE
INSERT INTO pedido_detalle (id_pedido, id_producto, id_variante, cantidad, precio_unitario)
VALUES
  (1, 1, 1, 1, 380000),
  (1, 2, NULL, 2, 500000);

-- PAGOS
INSERT INTO pagos (id_pedido, metodo_pago, estado_pago, id_transaccion, monto, fecha_pago)
VALUES
  (1, 'mercado_pago', 'aprobado', 'MP-123456', 1385000, NOW());

-- ENVIOS
INSERT INTO envios (id_pedido, destinatario, direccion_envio, ciudad, provincia, pais, codigo_postal, empresa_envio, numero_seguimiento, estado_envio, fecha_envio)
VALUES
  (1, 'Juan Pérez', 'Calle Falsa 123', 'Buenos Aires', 'Buenos Aires', 'Argentina', '1000', 'Andreani', 'ENV-987654', 'en_camino', NOW());

-- RESEÑAS
INSERT INTO reseñas (id_producto, id_usuario, calificacion, comentario)
VALUES
  (1, 1, 5, 'Excelente notebook, muy rápida'),
  (2, 1, 4, 'Muy buen celular pero un poco caro');

-- DESCUENTOS
INSERT INTO descuentos (codigo, descripcion, tipo, valor, fecha_inicio, fecha_fin)
VALUES
  ('BIENVENIDO10', '10% de descuento en tu primera compra', 'porcentaje', 10, '2025-01-01', '2025-12-31');

-- SOPORTE
INSERT INTO soporte (id_usuario, asunto, mensaje, canal)
VALUES
  (1, 'Problema con mi pedido', 'El envío figura como entregado pero no lo recibí', 'email');

-- LOGS
INSERT INTO logs (id_usuario, accion, ip, user_agent)
VALUES
  (1, 'Usuario inició sesión', '192.168.0.10', 'Mozilla/5.0'),
  (2, 'Admin creó nuevo producto', '192.168.0.20', 'Chrome/115');