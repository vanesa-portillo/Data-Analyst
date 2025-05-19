#Crear una BBDD
CREATE DATABASE transaction;

#Borrar una BBDD
DROP DATABASE transaction; 


#Crear la primera taula, la taula de fets
CREATE TABLE transactions (
	id VARCHAR(255) DEFAULT NULL, 
    card_id VARCHAR(255) DEFAULT NULL, 
    business_id VARCHAR(255) DEFAULT NULL, 
    timestamp DATETIME,
    amount DECIMAL(10,2), 
    declined TINYINT,
    product_ids VARCHAR(255) DEFAULT NULL,
    user_id VARCHAR(255) DEFAULT NULL,
    lat FLOAT DEFAULT NULL, 
    longitude FLOAT DEFAULT NULL);
    

#Muestra donde se alojan los archivos
SHOW variables like "secure_file_priv";
#Omplir la taula

#Introducir los datos en la tabla transactions
LOAD DATA 
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ';'
IGNORE 1 ROWS;

#Por si necesito borrar: 
DROP TABLE transactions;  

#Compruebo los datos
SELECT *
FROM transactions; 

#Renombro la columna para tener el mismo nombre en la otra tabla companies
ALTER TABLE transactions
RENAME COLUMN business_id TO company_id;

#Cambio tambien el campo card_id
ALTER TABLE transactions
RENAME COLUMN card_id TO credit_card_id;

#Compruebo los datos
SELECT *
FROM transactions; 

#Crear la tabla companies
CREATE TABLE companies (
	company_id VARCHAR(255) DEFAULT NULL, 
    company_name VARCHAR(255) DEFAULT NULL, 
    phone VARCHAR(255) DEFAULT NULL, 
    email VARCHAR(255) DEFAULT NULL,
    country VARCHAR(255) DEFAULT NULL, 
    website VARCHAR(255) DEFAULT NULL
    );
    
#Introducir los datos en la tabla companies
LOAD DATA 
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv"
INTO TABLE companies
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

#Comprobar los datos
SELECT *
FROM companies; 

#Crear la tabla credit_cards: 
CREATE TABLE credit_cards (
	id VARCHAR(255) DEFAULT NULL, 
    user_id VARCHAR(255) DEFAULT NULL, 
    iban VARCHAR(255) DEFAULT NULL, 
    pan VARCHAR(255) DEFAULT NULL,
    pin VARCHAR(255) DEFAULT NULL, 
    cvv VARCHAR(255) DEFAULT NULL, 
    track1 VARCHAR(255) DEFAULT NULL, 
    track2 VARCHAR(255) DEFAULT NULL, 
    expiring_date DATE DEFAULT NULL
    );
    
#Crear la tabla credit_cards: 
CREATE TEMPORARY TABLE credit_cards_temp(
	id VARCHAR(255) DEFAULT NULL, 
    user_id VARCHAR(255) DEFAULT NULL, 
    iban VARCHAR(255) DEFAULT NULL, 
    pan VARCHAR(255) DEFAULT NULL,
    pin VARCHAR(255) DEFAULT NULL, 
    cvv VARCHAR(255) DEFAULT NULL, 
    track1 VARCHAR(255) DEFAULT NULL, 
    track2 VARCHAR(255) DEFAULT NULL, 
    expiring_date VARCHAR(255) DEFAULT NULL
    );    
    
#Introducir los datos en la tabla credit_cards_temp
LOAD DATA 
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv"
INTO TABLE credit_cards_temp
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

#Inserto los datos a la tabla definitiva desde la tabla temporal
INSERT INTO credit_cards (id, user_id, iban, pan, pin, cvv, track1, track2, expiring_date)
SELECT id, user_id, iban, pan, pin, cvv, track1, track2, STR_TO_DATE(expiring_date, '%m/%d/%Y')
FROM credit_cards_temp;    

#Compruebo los datos
SELECT *
FROM credit_cards; 

#Borro los espacios vacios que existen en algunas lineas de la columna pan
UPDATE credit_cards
SET pan = REPLACE(pan, ' ', '');

#Elimino la tabla temporal para que no haya problemas con el nombre
DROP TEMPORARY table credit_cards_temp;

#Vuelvo a comprobar los datos
SELECT *
FROM credit_cards;

#Crear la tabla users 
CREATE TABLE users (
	id VARCHAR(255) DEFAULT NULL, 
    name VARCHAR(255) DEFAULT NULL, 
    surname VARCHAR(255) DEFAULT NULL, 
    phone VARCHAR(255) DEFAULT NULL,
    email VARCHAR(255) DEFAULT NULL, 
    birth_date VARCHAR(255) DEFAULT NULL, 
    country VARCHAR(255) DEFAULT NULL, 
    city VARCHAR(255) DEFAULT NULL, 
    postal_code VARCHAR(255) DEFAULT NULL, 
    address VARCHAR(255) DEFAULT NULL
    );
 
#Por si necesito borrar 
DROP table users;
    
#Introducir los datos en la tabla users del csv Canada:
LOAD DATA 
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv"
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

#Introducir los datos en la tabla users del csv UK:
LOAD DATA 
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv"
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

#Introducir los datos en la tabla users del csv USA:
LOAD DATA 
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv"
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

#Compruebo resultados
SELECT *
FROM users; 

#Ahora cambiaré los valores necesarios:  
ALTER TABLE users MODIFY COLUMN id INT NOT NULL; #tabla USERS 
ALTER TABLE transactions MODIFY COLUMN id VARCHAR(255) NOT NULL; #tabla transactions
ALTER TABLE credit_cards MODIFY COLUMN id VARCHAR(255) NOT NULL; #tabla credit_cards
ALTER TABLE companies MODIFY COLUMN company_id VARCHAR(255) NOT NULL; #tabla companies

#Indico las PK de cada tabla: 
ALTER TABLE users ADD PRIMARY KEY (id);
ALTER TABLE transactions ADD PRIMARY KEY (id);
ALTER TABLE credit_cards ADD PRIMARY KEY (id);
ALTER TABLE companies ADD PRIMARY KEY (company_id);

#Indico las FK de cada tabla: 
ALTER TABLE transactions ADD CONSTRAINT transactions_users FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE transactions ADD CONSTRAINT transactions_credit_cards FOREIGN KEY (credit_card_id) REFERENCES credit_cards(id);
ALTER TABLE transactions ADD CONSTRAINT transactions_companies FOREIGN KEY (company_id) REFERENCES companies(company_id);

#Compruebo las relaciones haciendo un join de las tablas
SELECT *
FROM transactions
INNER JOIN companies on transactions.company_id = companies.company_id
INNER JOIN credit_cards on transactions.credit_card_id = credit_cards.id
INNER JOIN users on transactions.user_id = users.id;

#Revisión
##Cambio el campo de company_id a id para tener un formato normalizado
ALTER TABLE companies
RENAME COLUMN id TO company_id;

#Nivell 1
#Exercici 1. Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.
SELECT users.id, users.name, users.surname
FROM users
WHERE id in
    (SELECT 
        user_id
    FROM
        transactions
    GROUP BY user_id
    HAVING COUNT(id) > 30); 
    

#Nivell 1
# Exercici 2. Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
SELECT iban, AVG(transactions.amount) AS Mitjana_amount
FROM credit_cards
INNER JOIN transactions ON credit_cards.id = transactions.credit_card_id
INNER JOIN companies ON companies.company_id = transactions.company_id
WHERE company_name like 'Donec Ltd'
GROUP BY iban
ORDER BY mitjana_amount;

SELECT *
FROM companies
WHERE company_name like 'DonecLtd';

#Nivell 2
# Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades
#Creo la tabla
CREATE TABLE credit_card_status AS
SELECT 
    credit_card_id,
    CASE 
        WHEN COUNT(*) = 3 AND SUM(declined) = 3 THEN 'Inactiva'
        ELSE 'Activa'
    END AS status
FROM (
    SELECT 
        credit_card_id, 
        declined,
        ROW_NUMBER() OVER (
            PARTITION BY credit_card_id 
            ORDER BY timestamp DESC
        ) AS ordered
    FROM transactions
) AS transacciones_ordenadas
WHERE ordered <= 3
GROUP BY credit_card_id;

#Por si necesito borrar: 
DROP table credit_card_status;

#Creo las relaciones: 
ALTER TABLE credit_card_status ADD CONSTRAINT credit_cards_status FOREIGN KEY (credit_card_id) REFERENCES credit_cards(id);

#Comprobar datos
SELECT *
FROM credit_card_status; 

#Comprobar relaciones
SELECT * 
FROM credit_card_status
INNER JOIN credit_cards ON credit_card_status.credit_card_id = credit_cards.id;

#Por si necesito borrar
DROP TABLE credit_card_status; 

#Nivell 2
#Exercici 1. Quantes targetes estan actives? 
SELECT count(credit_card_id) AS targetes_actives
FROM credit_card_status
WHERE status like 'activa'; 

#Nivell 3. Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada
#Crear la tabla products
CREATE TABLE products (
	id VARCHAR(255) DEFAULT NULL, 
    product_name VARCHAR(255) DEFAULT NULL, 
    price DECIMAL(10,2) DEFAULT NULL, 
    colour VARCHAR(255) DEFAULT NULL,
    weight VARCHAR(255) DEFAULT NULL, 
    warehouse_id VARCHAR(255) DEFAULT NULL
    );
    
#Por si necesito borrar
DROP TABLE products; 

#Introducir los datos en la tabla products:
LOAD DATA 
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv"
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, product_name, @price, colour, weight, warehouse_id)
SET price = REPLACE(@price, '$', '');

#Compruebo los datos introducidos: 
SELECT *
FROM products; 

#Crear la PK de la tabla products:    
ALTER TABLE products ADD PRIMARY KEY (id);

#Observo que en la tabla transaction en cada linea hay varios productos
#Tengo que crear una tabla intermedia entre transactions y products
CREATE TABLE transactions_products (
    transaction_id VARCHAR(255),  
    product_id VARCHAR(255),
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    FOREIGN KEY (product_id) REFERENCES products(id));

#Por si necesito borrar: 
DROP TABLE transactions_products;

#Consulta de la tabla transactions_products
SELECT *
FROM transactions_products;

#Consulta de la tabla transactions
select *
from transactions;

#Insertar los datos indicando que los productos de la tabla transactions se deben separar: 
INSERT INTO transactions_products (transaction_id, product_id)
SELECT transactions.id AS transaction_id, jt.product_id
FROM transactions
INNER JOIN JSON_TABLE(CONCAT('[', transactions.product_ids, ']'), '$[*]' COLUMNS (product_id INT PATH '$')) AS jt;

#Comprobar los datos: 
SELECT *
FROM transactions_products;

#Comprobar las relaciones: 
SELECT *
FROM transactions_products
INNER JOIN transactions ON transactions.id = transactions_products.transaction_id
ORDER BY transaction_id;

#Nivell 3
#Exercici 1. Necessitem conèixer el nombre de vegades que s'ha venut cada producte. 
SELECT product_id, products.product_name, count(transactions.id) AS n_vegades
FROM transactions
INNER JOIN transactions_products ON transactions.id = transactions_products.transaction_id
INNER JOIN products ON products.id = transactions_products.product_id
GROUP BY transactions_products.product_id
ORDER BY product_id ASC;
