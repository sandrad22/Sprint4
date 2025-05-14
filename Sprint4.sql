CREATE SCHEMA data;
USE data;

CREATE TABLE IF NOT EXISTS companies (
company_id VARCHAR(15),
company_name VARCHAR(255),
phone VARCHAR(15),
email VARCHAR(100),
country VARCHAR(100),
website VARCHAR(255) 
);


LOAD DATA INFILE 'C:\Users\formacio\Desktop\companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


SHOW VARIABLES LIKE "secure_file_priv";

'secure_file_priv', 'C:\\ProgramData\\MySQL\\MySQL Server 8.4\\Uploads\\'



# Nivell 1
# Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys 4 taules de les quals puguis realitzar les següents consultes:



# Exercici 1
# Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.


# Exercici 2
# Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.




# Nivell 2
# Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i genera la següent consulta:

# Exercici 1
# Quantes targetes estan actives?




# Nivell 3
# Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

# Exercici 1
# Necessitem conèixer el nombre de vegades que s'ha venut cada producte.



