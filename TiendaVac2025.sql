CREATE DATABASE TiendaVac2025;
USE TiendaVac2025;
CREATE TABLE Productos(
	id INT auto_increment PRIMARY KEY,
	nombre VARCHAR(50) UNIQUE NOT NULL,
    tipo ENUM('papeleria','supermercado','drogueria') NOT NULL,
    cantidad_actual INT NOT NULL,
    cantidad_minima INT NOT NULL,
    precio_base DECIMAL(10,2) NOT NULL
);

CREATE TABLE Ventas(
	id INT auto_increment primary key,
    producto_id INT not null,
    cantidad int not null,
    fecha date not null,
    foreign key (producto_id) references Productos(id)
);

INSERT INTO Productos (nombre, tipo, cantidad_actual, cantidad_minima, precio_base)
    VALUES 
        ('Lapiz', 'papeleria', 100, 5, 2.50),
        ('Leche', 'supermercado', 50, 10, 2.00),
        ('Arroz', 'supermercado', 50, 20, 3.50),
        ('Agua', 'drogueria', 40, 10, 1.7),
        ('Suero', 'drogueria', 80, 5, 4.50);
        
        
INSERT INTO Ventas (producto_id, cantidad, fecha)
    VALUES
        (1, 10, '2025-01-01'),
        (2, 3, '2025-01-12'),
        (4, 5, '2025-01-06'),
        (5, 2, '2025-01-03'),
        (3, 4, '2025-01-07');        

SELECT * FROM productos;
SELECT * FROM ventas;
-- 1. Visualizar la información de los productos

CREATE VIEW vista_productos AS
SELECT 
    p.id,
    p.nombre,
    p.tipo,
    p.cantidad_actual,
    p.cantidad_minima,
    p.precio_base,
    CASE 
        WHEN p.tipo = 'papeleria' THEN p.precio_base * 1.16
        WHEN p.tipo = 'drogueria' THEN p.precio_base * 1.12
        WHEN p.tipo = 'supermercado' THEN p.precio_base * 1.04
    END AS precio_final    
FROM
    Productos p;

-- 2. Vender un producto
DELIMITER $$
CREATE PROCEDURE vender_producto(
    producto_id INT,
    cantidad INT
)
BEGIN
    DECLARE precio_final DECIMAL(10,2);
    DECLARE stock_actual INT;

    SELECT cantidad_actual INTO stock_actual
    FROM Productos
    WHERE id = producto_id;

    IF stock_actual >= cantidad THEN
        UPDATE Productos
        SET cantidad_actual = cantidad_actual - cantidad
        WHERE id = producto_id;

        SELECT 
            CASE
                WHEN tipo = 'papeleria' THEN precio_base*1.16
                WHEN tipo = 'drogueria' THEN precio_base*1.12
                WHEN tipo = 'supermercado' THEN precio_base*1.04
            END INTO precio_final
        FROM
            Productos
        WHERE
            id = producto_id;

        INSERT INTO Ventas (producto_id, cantidad, fecha)
        VALUES (producto_id, cantidad, CURDATE());
        
        SELECT CONCAT('Venta realizada. Total de:', precio_final*cantidad) AS Mensaje;
    ELSE
        SELECT 'No hay suficiente stock.' AS Mensaje;
    END IF;      
END$$
DELIMITER ;

CALL vender_producto (1,1);

-- 3. Abastecer la tienda con un producto

DELIMITER $$
CREATE PROCEDURE abastecer_producto(
    producto_id INT,
    cantidad INT
)
BEGIN
    UPDATE Productos
    SET cantidad_actual = cantidad_actual + cantidad
    WHERE id = producto_id;

    SELECT CONCAT('Se ha abastecido, cantidad actual:', cantidad_actual,'unidades del producto.', nombre) AS Mensaje
    FROM Productos
    WHERE id = producto_id;
END$$
DELIMITER ;

CALL abastecer_producto(1,1);

-- 4. Cambiar un producto de la tienda   

DELIMITER $$
CREATE PROCEDURE cambiar_producto(
    producto_id INT,
    nuevo_nombre VARCHAR(50),
    nuevo_tipo ENUM('papeleria','supermercado','drogueria'),
    nuevo_precio_base DECIMAL(10,2)
)

BEGIN   
    DECLARE existe_nombre BOOLEAN;

    SELECT COUNT(*) > 0 INTO existe_nombre
    FROM Productos
    WHERE nombre = nuevo_nombre AND id <> product_id;

    IF NOT existe_nombre THEN
        UPDATE Productos
        SET nombre = nuevo_nombre,
            tipo = nuevo_tipo,
            precio_base = nuevo_precio_base
        WHERE id = producto_id;

        SELECT CONCAT('Producto cambiado correctamente.') AS Mensaje;
        
    ELSE
        SELECT 'El nombre del producto ya existe.' AS Mensaje;
        
    END IF;
END$$
DELIMITER ;

-- 5. Calcular estadísticas de ventas:

CREATE VIEW vista_estadisticas AS
SELECT 
    (
        SELECT p.nombre
        FROM Productos p  
        INNER JOIN Ventas v ON p.id = v.producto_id
        GROUP BY p.id
        ORDER BY sum(v.cantidad) DESC -- ASC
        LIMIT 1
    ) AS producto_mas_vendido,
    (
        SELECT p.nombre
        FROM Productos p  
        INNER JOIN Ventas v ON p.id = v.producto_id
        GROUP BY p.id
        ORDER BY sum(v.cantidad) ASC -- ASC
        LIMIT 1
    ) AS producto_menos_vendido,
    (
        SELECT sum(p.precio_base * v.cantidad * 
            CASE
                WHEN p.tipo= 'papeleria' THEN 1.16
                WHEN p.tipo= 'drogueria' THEN 1.12
                WHEN p.tipo= 'supermercado' THEN 1.04
            END) 
        FROM Productos p  
        INNER JOIN Ventas v ON p.id = v.producto_id
    ) AS total_ventas,
    (
        SELECT SUM(p.precio_base*
            CASE
                WHEN p.tipo= 'papeleria' THEN 1.16
                WHEN p.tipo= 'drogueria' THEN 1.12
                WHEN p.tipo= 'supermercado' THEN 1.04
            END) / sum(v.cantidad)
        FROM Productos p  
        INNER JOIN Ventas v ON p.id = v.producto_id
    ) AS promedio_ventas;
    
    select * from vista_estadisticas;
    
DELIMITER $$
CREATE PROCEDURE menu()
BEGIN
    DECLARE opcion INT; -- C++ int opcion

    SELECT '
    ======= MENÚ PRINCIPAL ===== 
    1. Visualizar la información de los productos
    2. Vender un producto.
    3. Abastecer la tienda con un producto.
    4. Cambiar un producto.
    5. Estadisticas de ventas.
    0. Salir' INTO @menu;

    -- Asignar la opción directamente para probar 

    SET opcion = 4; -- Cambiar esto por la opción deseada
    AppMenuLoop: LOOP
    CASE opcion
        WHEN 1 THEN
            SELECT * FROM vista_productos;
        WHEN 2 THEN
            -- Valores de prueba para los parámetros del procedimiento de ventas
            SET @producto_id = 1;
            SET @cantidad = 3;
            CALL vender_producto(@producto_id, @cantidad);
        WHEN 3 THEN
        -- Valores de prueba para los parámetros del procedimiento de abastecer
            SET @producto_id = 1;
            SET @cantidad = 1;
            CALL abastecer_producto(@producto_id, @cantidad);
        WHEN 4 THEN
        -- Valores de prueba para los parámetros del procedimiento de cambiar
            SET @producto_id = 2; 
            SET @nuevo_nombre = 'Ibuprofeno';
            SET @nuevo_tipo = 'drogueria';
            SET @nuevo_precio_base = 4.50;
            CALL cambiar_producto(@producto_id, @nuevo_nombre, @nuevo_tipo, @nuevo_precio_base);
        WHEN 5 THEN
            SELECT * FROM vista_estadisticas;
        WHEN 0 THEN
            LEAVE AppMenuLoop;
        ELSE
            SELECT 'Opción no válida.';
    END CASE;
    SET opcion=0;
    END LOOP AppMenuLoop;                       
END$$
DELIMITER ;

call menu;