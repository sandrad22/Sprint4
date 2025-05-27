CREATE SCHEMA data;
USE data;

# NIVELL 1
# Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys 4 taules de les quals puguis realitzar les següents consultes:

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

CREATE TABLE IF NOT EXISTS users (
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
     FOREIGN KEY (user_id) REFERENCES users(id)
    );

SHOW VARIABLES LIKE "secure_file_priv";

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.4\\Uploads\\companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','       # indica que los campos están separados por una coma
ENCLOSED BY '"'                # indica que los valores contienen un separador de campos o la terminación de línea, garantiza la integridad de los datos y evita errores de parsing.
LINES TERMINATED BY '\n'       # indica que las líneas están separadas por un carácter de nueva línea \n
IGNORE 1 ROWS;			       # ignora la primera línea porque es un encabezado

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.4\\Uploads\\credit_cards.csv'
INTO TABLE credit_card
FIELDS TERMINATED BY ','   
ENCLOSED BY '"'            
LINES TERMINATED BY '\n'   
IGNORE 1 ROWS;			   

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.4\\Uploads\\users_ca.csv'
INTO TABLE users
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'           
LINES TERMINATED BY '\r\n'     # indica que el archivo de texto ha sido creado en Windows CRLF y utiliza \r\n como terminador de línea.
IGNORE 1 ROWS;			  

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.4\\Uploads\\users_uk.csv'
INTO TABLE users
FIELDS TERMINATED BY ','   
ENCLOSED BY '"'            
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;			   

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.4\\Uploads\\users_usa.csv'
INTO TABLE users
FIELDS TERMINATED BY ','   
ENCLOSED BY '"'            
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;			   

#SET foreign_key_checks = 0;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.4\\Uploads\\transactions.csv'     # se carga en último lugar por las FK's
INTO TABLE transactions
FIELDS TERMINATED BY ';'   # indica que los campos están separados por punto y coma
ENCLOSED BY '"'           
LINES TERMINATED BY '\n'  
IGNORE 1 ROWS;			  

#SET foreign_key_checks = 1;


# Exercici 1
# Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.

SELECT t.user_id AS 'Id. usuario', u.name AS Nombre, u.surname AS Apellido, COUNT(*) AS Num_Transacciones   
FROM transactions t
JOIN users u
ON t.user_id = u.id
WHERE t.declined = 0
GROUP BY t.user_id, u.name, u.surname
HAVING Num_Transacciones > 30;


#SELECT t.user_id AS 'Id. usuario', u.name AS Nombre, u.surname AS Apellido, t.declined, COUNT(*)
#FROM transactions t
#JOIN users u
#ON t.user_id = u.id
#WHERE t.user_id = 275
#GROUP BY t.declined;



# Exercici 2
# Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

SELECT cc.iban AS IBAN, AVG(tr.amount) AS Media_Amount
FROM transactions tr
JOIN credit_card cc
ON tr.card_id = cc.id
JOIN companies co
ON tr.business_id = co.company_id
WHERE co.company_name = 'Donec Ltd' AND tr.declined = 0
GROUP BY cc.iban;


# NIVELL 2
# Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i genera la següent consulta:

#DROP TABLE estado_tarjetas;

CREATE TABLE estado_tarjetas AS          
SELECT 
    card_id, 
    CASE
        WHEN SUM(									# la variable declined es booleana y, aunque podría sumar el valor 1, podría dar error
				CASE                                
					WHEN declined = 1 THEN 1
                    ELSE 0 
				END) = 3 THEN 0
        ELSE 1
    END AS tarjeta_activa               
FROM 
    (SELECT card_id, declined, 
         ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY timestamp DESC) AS cuenta_transacciones
     FROM transactions
    ) AS ordena_transacciones
WHERE cuenta_transacciones <= 3 
GROUP BY card_id;


# Exercici 1
# Quantes targetes estan actives?

SELECT COUNT(*) AS 'Número de tarjetas activas'
FROM estado_tarjetas
WHERE tarjeta_activa = 1;



# NIVELL 3
# Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

CREATE TABLE IF NOT EXISTS products (
	id VARCHAR(30) PRIMARY KEY,
	product_name VARCHAR(255),
	price VARCHAR(10),
	colour VARCHAR(15),
	weight FLOAT,
	warehouse_id VARCHAR(10) 
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.4\\Uploads\\products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','   
ENCLOSED BY '"'            
LINES TERMINATED BY '\n'   
IGNORE 1 ROWS;			   


CREATE TABLE transaction_products (
    transaction_id VARCHAR(255),
    product_id VARCHAR(30),
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO transaction_products (transaction_id, product_id)
SELECT tr.id, pr.id
FROM transactions tr
JOIN products pr
ON FIND_IN_SET(pr.id, REPLACE(tr.products_ids, ' ', ''));


# Exercici 1
# Necessitem conèixer el nombre de vegades que s'ha venut cada producte.

SELECT product_id AS 'Identificador del producto', product_name AS 'Nombre del producto', COUNT(*) AS 'Número de Ventas'
FROM transaction_products tp
JOIN products p
ON tp.product_id = p.id 
JOIN transactions t
ON tp.transaction_id = t.id
WHERE declined = 0
GROUP BY tp.product_id, p.product_name
ORDER BY p.product_name;





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



