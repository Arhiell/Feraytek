-- Testing --

USE feraytek;
-- 8) Traer todos los datos del administrador --
SELECT 
    u.id_usuario,
    u.email,
    u.rol,
    u.estado,
    a.id_admin,
    a.dni,
    a.nombre,
    a.apellido,
    a.telefono,
    a.cargo,
    u.fecha_registro,
    u.ultimo_login
FROM administradores a
INNER JOIN usuarios u ON a.id_usuario = u.id_usuario;


-- 7) Traer todos los datos del cliente (perfil completo) --
SELECT 
    u.id_usuario,
    u.email,
    u.rol,
    u.estado,
    c.id_cliente,
    c.dni,
    c.nombre,
    c.apellido,
    c.telefono,
    c.direccion,
    c.ciudad,
    c.provincia,
    c.pais,
    c.codigo_postal,
    c.fecha_nacimiento,
    u.fecha_registro,
    u.ultimo_login
FROM clientes c
INNER JOIN usuarios u ON c.id_usuario = u.id_usuario;


-- 6. Testear consultas reales (flujo completo) --
-- 1. Ver productos con sus categorías y variantes
SELECT p.nombre, c.nombre_categoria, v.atributo, v.valor, v.precio
FROM productos p
JOIN categorias c ON p.id_categoria = c.id_categoria
LEFT JOIN variantes_producto v ON p.id_producto = v.id_producto;

-- 2. Ver el carrito de un usuario con detalle
SELECT u.email, p.nombre, cd.cantidad, cd.precio_unitario
FROM carrito ca
JOIN usuarios u ON ca.id_usuario = u.id_usuario
JOIN carrito_detalle cd ON ca.id_carrito = cd.id_carrito
JOIN productos p ON cd.id_producto = p.id_producto
WHERE u.id_usuario = 1;

-- 3. Ver un pedido completo con pago y envío
SELECT pe.id_pedido, u.email, pe.total, pa.estado_pago, en.estado_envio
FROM pedidos pe
JOIN usuarios u ON pe.id_usuario = u.id_usuario
LEFT JOIN pagos pa ON pe.id_pedido = pa.id_pedido
LEFT JOIN envios en ON pe.id_pedido = en.id_pedido
WHERE pe.id_pedido = 1;


-- 5. Testear unicidad de detalle (carrito y pedido)
-- Duplicados en carrito (no debería devolver filas)
SELECT id_carrito, id_producto, IFNULL(id_variante,0) as variante, COUNT(*) as cantidad
FROM carrito_detalle
GROUP BY id_carrito, id_producto, variante
HAVING COUNT(*) > 1;

-- Duplicados en pedido (no debería devolver filas)
SELECT id_pedido, id_producto, IFNULL(id_variante,0) as variante, COUNT(*) as cantidad
FROM pedido_detalle
GROUP BY id_pedido, id_producto, variante
HAVING COUNT(*) > 1;


-- 4.Validar reglas de negocio (CHECK constraints) --
-- Buscar precios negativos (no debería haber)
SELECT * FROM productos WHERE precio_base < 0;
SELECT * FROM variantes_producto WHERE precio < 0;

-- Buscar stock negativo
SELECT * FROM productos WHERE stock < 0;
SELECT * FROM variantes_producto WHERE stock < 0;

-- Buscar pedidos con total < 0
SELECT * FROM pedidos WHERE total < 0;

-- Buscar reseñas fuera de rango (1 a 5)
SELECT * FROM reseñas WHERE calificacion < 1 OR calificacion > 5;


-- 3. Validar integridad referencial (FKs)-- 
-- Clientes que apuntan a un usuario inexistente
SELECT c.*
FROM clientes c
LEFT JOIN usuarios u ON c.id_usuario = u.id_usuario
WHERE u.id_usuario IS NULL;

-- Carritos sin usuario válido
SELECT ca.*
FROM carrito ca
LEFT JOIN usuarios u ON ca.id_usuario = u.id_usuario
WHERE u.id_usuario IS NULL;

-- Pedidos sin usuario válido
SELECT p.*
FROM pedidos p
LEFT JOIN usuarios u ON p.id_usuario = u.id_usuario
WHERE u.id_usuario IS NULL;

-- Pedido_detalle con producto inexistente
SELECT pd.*
FROM pedido_detalle pd
LEFT JOIN productos pr ON pd.id_producto = pr.id_producto
WHERE pr.id_producto IS NULL;


-- 2. Testear índices (performance y búsqueda rápida) --
-- Buscar un usuario por email (aprovecha índice UNIQUE en usuarios.email)
EXPLAIN SELECT * FROM usuarios WHERE email = 'juanperez@gmail.com';

-- Buscar productos por nombre (usa índice idx_prod_nombre)
EXPLAIN SELECT * FROM productos WHERE nombre LIKE '%Notebook%';

-- Buscar pedidos de un usuario (usa índice idx_pedidos_user_fecha)
EXPLAIN SELECT * FROM pedidos WHERE id_usuario = 1 ORDER BY fecha_pedido DESC;

-- Buscar envíos por estado (usa índice idx_envios_estado)
EXPLAIN SELECT * FROM envios WHERE estado_envio = 'en_camino';

-- 1. Validar índices únicos (email y DNI) --
-- Buscar emails duplicados en usuarios (no debería devolver filas)
SELECT email, COUNT(*) as cantidad
FROM usuarios
GROUP BY email
HAVING COUNT(*) > 1;

-- Buscar DNI duplicados en clientes
SELECT dni, COUNT(*) as cantidad
FROM clientes
GROUP BY dni
HAVING COUNT(*) > 1;

-- Buscar DNI duplicados en administradores
SELECT dni, COUNT(*) as cantidad
FROM administradores
GROUP BY dni
HAVING COUNT(*) > 1;