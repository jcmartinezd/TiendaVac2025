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
        ('Leche', 'supermercado',50,10, 2.00),
        ('Arroz', 'supermercado',50,20, 3.50),
        ('Agua', 'drogueria',40,10, 1.7),
        ('Suero','drogueria',80,5, 4.50);
        
        
INSERT INTO Ventas (producto_id, cantidad, fecha)
    VALUES
        (1, 10, '2025-01-01'),
        (2, 3, '2025-01-12'),
        (4, 5, '2025-01-06'),
        (5,2,"")
        