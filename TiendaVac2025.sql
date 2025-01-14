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