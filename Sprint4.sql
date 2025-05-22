CREATE SCHEMA data;

# NIVELL 1
# Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys 4 taules de les quals puguis realitzar les següents consultes:

USE data;

CREATE TABLE IF NOT EXISTS companies (
	company_id VARCHAR(15) PRIMARY KEY,
	company_name VARCHAR(255),
	phone VARCHAR(15),
	email VARCHAR(100),
	country VARCHAR(100),
	website VARCHAR(255) 
);

CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(20) PRIMARY KEY,
	user_id INT,
	iban VARCHAR(50), 
	pan VARCHAR(20),
	pin VARCHAR(20),
	cvv INT,
	track1 VARCHAR(255),
	track2 VARCHAR(255),
	expiring_date VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS products (
	id INT PRIMARY KEY,
	product_name VARCHAR(255),
	price VARCHAR(10),
	colour VARCHAR(15),
	weight FLOAT,
	warehouse_id VARCHAR(10) 
);

CREATE TABLE IF NOT EXISTS users_ca (
       id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255)
	);

CREATE TABLE IF NOT EXISTS users_uk (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255)        
    );

CREATE TABLE IF NOT EXISTS users_usa (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255)        
    );

CREATE TABLE IF NOT EXISTS transactions (
     id VARCHAR(255) PRIMARY KEY,
     card_id VARCHAR(20),
     business_id VARCHAR(20), 
     timestamp VARCHAR(30),
     amount DECIMAL(10, 2),
     declined BOOLEAN,
     products_ids VARCHAR(30),
     user_id INT, 
     lat FLOAT,
     longitude FLOAT,
     FOREIGN KEY (card_id) REFERENCES credit_card(id),
     FOREIGN KEY (business_id) REFERENCES companies(company_id),
     FOREIGN KEY (user_id) REFERENCES users_ca(id),
     FOREIGN KEY (user_id) REFERENCES users_uk(id),
     FOREIGN KEY (user_id) REFERENCES users_usa(id)
    );


SHOW VARIABLES LIKE "secure_file_priv";


LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.4\\Uploads\\companies (1).csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.4\\Uploads\\credit_cards (1).csv'
INTO TABLE credit_card
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.4\\Uploads\\products (1).csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.4\\Uploads\\users_ca (1).csv'
INTO TABLE users_ca
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'    # Al tratarse de un archivo windows CRLF llevan oculto al final de la línea ciertos símbolos y es necesario poner esta instruccion
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.4\\Uploads\\users_uk (1).csv'
INTO TABLE users_uk
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'    # Al tratarse de un archivo windows CRLF llevan oculto al final de la línea ciertos símbolos y es necesario poner esta instruccion
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.4\\Uploads\\users_usa.csv'
INTO TABLE users_usa
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'    # Al tratarse de un archivo windows CRLF llevan oculto al final de la línea ciertos símbolos y es necesario poner esta instruccion
IGNORE 1 ROWS;

SET foreign_key_checks = 0;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.4\\Uploads\\transactions (1).csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET foreign_key_checks = 1;


# Exercici 1
# Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.

SELECT u.name AS Nombre, u.surname AS Apellido, COUNT(*) AS Num_Transacciones
FROM transactions t
JOIN 
	(
	SELECT * 
	FROM users_ca 
	UNION 
	SELECT * 
	FROM users_uk 
	UNION 
	SELECT * 
	FROM users_usa 
    ) u
ON t.user_id = u.id
GROUP BY user_id, u.name, u.surname
HAVING Num_Transacciones > 30;


# Exercici 2
# Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

SELECT iban AS IBAN, AVG(amount) AS Media_Amount
FROM transactions t
LEFT JOIN credit_card cc
ON t.card_id = cc.id
LEFT JOIN companies co
ON t.business_id = co.company_id
WHERE company_name = 'Donec Ltd'
GROUP BY iban;



# NIVELL 2
# Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i genera la següent consulta:

#DROP TABLE estado_tarjetas;

CREATE TABLE estado_tarjetas AS
SELECT 
    card_id, 
    CASE
        WHEN SUM(
				CASE 
					WHEN declined = 1 THEN 1 
                    ELSE 0 
				END) = 3 THEN 0
        ELSE 1
    END AS tarjeta_activa               
FROM 
    (SELECT card_id, declined, 
         ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY timestamp DESC) AS contador
     FROM transactions
    ) orden
WHERE contador <= 3 
GROUP BY card_id;


# Exercici 1
# Quantes targetes estan actives?

SELECT COUNT(*) AS 'Número de tarjetas activas'
FROM estado_tarjetas
WHERE tarjeta_activa = 1;



# NIVELL 3
# Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

#DROP TABLE productos_por_transaccion;

CREATE TABLE productos_por_transaccion AS
SELECT pr.id AS product_id, pr.product_name, pr.price, pr.colour, pr.weight, pr.warehouse_id, tr.id AS transaction_id
FROM transactions tr
JOIN products pr 
ON FIND_IN_SET(pr.id, REPLACE(tr.products_ids, ' ', ''));


# Exercici 1
# Necessitem conèixer el nombre de vegades que s'ha venut cada producte.

SELECT product_id AS 'Identificador del producto', product_name AS 'Nombre del producto', COUNT(*) AS 'Número de Ventas'
FROM productos_por_transaccion
GROUP BY product_id, product_name
ORDER BY  product_name;








# Transformar variable expiring_date en fecha  ###################

#ALTER TABLE credit_card
#ADD exp_date DATE;

#SET SQL_SAFE_UPDATES = 0;
#UPDATE credit_card
#SET exp_date = STR_TO_DATE(expiring_date, '%m/%d/%y');
#SET SQL_SAFE_UPDATES = 1;

#ALTER TABLE credit_card
#DROP COLUMN expiring_date;

#ALTER TABLE credit_card
#RENAME COLUMN exp_date to expiring_date;

