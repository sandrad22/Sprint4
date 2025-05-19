CREATE SCHEMA data;

# Nivell 1
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


#SET foreign_key_checks = 0;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.4\\Uploads\\transactions (1).csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#SET foreign_key_checks = 1;


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


#SELECT user_id, COUNT(*) AS Num_Transacciones
#FROM transactions
#GROUP BY user_id
#HAVING Num_Transacciones > 30;


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



# Nivell 2
# Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i genera la següent consulta:

select card_id, timestamp, declined
from transactions
GROUP BY card_id, timestamp, declined
order by card_id, timestamp, declined DESC
;



          
          

CREATE TABLE artists_and_works
  SELECT artist.name, COUNT(work.artist_id) AS number_of_works
  FROM artist LEFT JOIN work ON artist.id = work.artist_id
  GROUP BY artist.id;


# Exercici 1
# Quantes targetes estan actives?




# Nivell 3
# Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de transaction tens product_ids. Genera la següent consulta:



# Exercici 1
# Necessitem conèixer el nombre de vegades que s'ha venut cada producte.






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
