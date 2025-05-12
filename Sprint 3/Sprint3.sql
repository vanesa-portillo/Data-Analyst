
SHOW CREATE TABLE transaction; 

SELECT *
FROM transaction; 

#NIVELL 1

#EJERCICIO 1
SHOW CREATE TABLE company; #buscamos el codigo con que se creo la tabla company para utilizarlo de base para crear la tabla credit_card

CREATE TABLE credit_card_def ( #crear tabla donde tambien indicamos la PK
  id varchar(15) NOT NULL,
  iban varchar(50) DEFAULT NULL,
  pan varchar(50) NOT NULL, #mas adelante me doy cuenta que necesito que pueda ser nulo
  pin varchar(50) DEFAULT NULL,
  cvv int DEFAULT NULL,
  expiring_date DATE DEFAULT NULL,
  PRIMARY KEY (`id`) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

drop table credit_card_def; #el codigo para borrar la tabla por si hago algo mal

#Aqui creo una tabla temporal para que me ingrese los datos de la fecha correctamente
CREATE TEMPORARY TABLE credit_card ( 
  id VARCHAR(15),  
  iban VARCHAR(50),
  pan VARCHAR(50),
  pin VARCHAR(50),
  cvv VARCHAR(50),
  expiring_date VARCHAR(50) 
);
#Inserto los datos ejecutando el script aportado

#Inserto los datos el tabla definitiva desde la tabla temporal
INSERT INTO credit_card_def (id, iban, pan, pin, cvv, expiring_date)
SELECT id, iban, pan, pin, cvv, STR_TO_DATE(expiring_date, '%m/%d/%Y')
FROM credit_card;

#Verifico que la tabla se ha creado correctamente
SELECT *
FROM credit_card_def;

#poner los resultados definitivos. 

#Elimino la tabla temporal para que no haya problemas con el nombre
DROP TEMPORARY table credit_card;

#Renombro la tabla definitiva
RENAME TABLE credit_card_def TO credit_card; 

#Relacionamos la tabla transaction con la tabla credit_card indicando 
# la FK en la tabla transaction

ALTER TABLE transaction
ADD CONSTRAINT transaction_creditcard
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);

#Compruebo que funciona correctamente uniendo las tablas por la columna asignada
SELECT *
FROM credit_card
INNER JOIN transaction 
ON credit_card.id = transaction.credit_card_id;

#Borro los espacios vacios que existen en algunas lineas de la columna pan
UPDATE credit_card
SET pan = REPLACE(pan, ' ', '');

#Compruebo que queda todo correcto
SELECT *
FROM credit_card;

#Nivel 1
#Ejercicio 2
#El departament de Recursos Humans ha identificat un error en el número de compte de 
# l'usuari amb ID CcU-2938. 
# La informació que ha de mostrar-se per a aquest registre és: R323456312213576817699999. 
# Recorda mostrar que el canvi es va realitzar. 

SELECT id, iban #Compruebo el usuario
FROM credit_card
WHERE id = 'CcU-2938'; 

UPDATE credit_card #Realizo el cambio
SET iban = 'R323456312213576817699999'
WHERE id = 'CcU-2938';

SELECT id, iban #Vuelvo a comprobar que el cambio se hizo correctamente
FROM credit_card
WHERE id = 'CcU-2938'; 

#Nivel 1
#Ejercicio 3

#Uno las tres tablas para ver la información 
SELECT *
FROM credit_card
INNER JOIN transaction 
ON credit_card.id = transaction.credit_card_id
INNER JOIN company
ON transaction.company_id = company.id;

#Me doy cuenta que puse el PAN como valor no nulo y tengo que cambiarlo
ALTER TABLE credit_card
MODIFY pan varchar(50) DEFAULT NULL;

#Primero inserto datos en la tabla credit_card
INSERT INTO credit_card (id)
VALUES ('CcU-9999');

#Inserto los datos en la tabla transaction
INSERT INTO transaction (id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 9999, 829.999, -117.999, 111.11, 0); 

#Inserto los datos en la tabla company
INSERT INTO company (id)
VALUES ('b-9999');

#Al intentar mostrar los resultados, me doy cuenta que en la tabla transaction no he puesto los valores que relacionan con las otras tablas
UPDATE transaction 
SET credit_card_id = 'CcU-9999', 
	company_id = 'b-9999'
WHERE id like '108B1D1D-5B23-A76C-55EF-C568E49A99DD';


SELECT t.id as Id, t.user_id, t.lat, t.longitude, t.amount, t.declined, credit_card.id as credit_card_id, company.id as company_id 
FROM transaction as t
INNER JOIN credit_card on t.credit_card_id = credit_card.id
INNER JOIN company on company.id = t.company_id
WHERE t.id like '108B1D1D-5B23-A76C-55EF-C568E49A99DD'
AND credit_card.id like 'CcU-9999'
AND company.id like 'b-9999'; 

#Esto no hacer caso, lo tuve que cambiar mas adelante.
ALTER TABLE company
MODIFY id varchar(20);

#Nivell 1
#Ejercicio 4

SELECT *
FROM credit_card;

ALTER TABLE credit_card
DROP COLUMN pan; 

SELECT *
FROM credit_card; 

#Nivell 2
#Ejercicio 1
#Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades. 

#Primero reviso los datos: 
SELECT *
FROM transaction
WHERE id like '02C6201E-D90A-1859-B4EE-88D2986D3B02';

#Comando para eliminar un registro
DELETE
FROM transaction
WHERE id like '02C6201E-D90A-1859-B4EE-88D2986D3B02';

#Comando para comprobar que se ha borrado correctamente
SELECT *
FROM transaction
WHERE id like '02C6201E-D90A-1859-B4EE-88D2986D3B02';

#Nivell 2
#Ejercicio 2

CREATE VIEW VistaMarketing AS
SELECT 
    company.company_name AS NomCompanyia,
    company.phone AS Telefon,
    company.country AS Pais,
    AVG(transaction.amount) AS MitjanaCompra
FROM 
    company
JOIN 
    transaction ON company.id = transaction.company_id
GROUP BY 
    company.company_name, company.country, company.phone
ORDER BY 
    MitjanaCompra DESC;
    
SELECT *
FROM VistaMarketing;

#Nivell 2
#Ejercicio 3

SELECT * 
FROM VistaMarketing
WHERE Pais like 'Germany';

#Nivell 3
#Ejercicio 1

#Tengo que quitar primero la FK

ALTER TABLE transaction
DROP FOREIGN KEY transaction_creditcard;

ALTER TABLE transaction
DROP FOREIGN KEY transaction_ibfk_1;

ALTER TABLE transaction
DROP FOREIGN KEY transaction_company;

#Introduzco de nuevo la FK
ALTER TABLE transaction
ADD CONSTRAINT transaction_company
FOREIGN KEY (company_id)
REFERENCES company(id);

#Elimino la columna website de la tabla company:
ALTER TABLE company
DROP COLUMN website; 

#Modifico lo necesario en la tabla credit_card:
ALTER TABLE credit_card
MODIFY id varchar(20);

ALTER TABLE credit_card
MODIFY pin varchar(4);

#Modifico la expiring_date de fecha a varchar: 
ALTER TABLE credit_card
MODIFY COLUMN expiring_date VARCHAR(20);

#Añado la columna fecha_actual: 
ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE; 

#Actualizo la tabla con la fecha actual: 
UPDATE credit_card
SET fecha_actual = CURDATE(); 

#Creada y rellenada la tabla de user
#Modificamos el campo email por personal_email
ALTER TABLE user
RENAME COLUMN email TO peronal_email;

#Al corregir me doy cuenta que tengo el mal el nombre: 
ALTER TABLE data_user
RENAME COLUMN peronal_email TO personal_mail; 

#Cambiamos el nombre de la tabla:
RENAME TABLE user TO data_user;  

#Hay que añadir el usuario 9999
INSERT INTO data_user (id)
VALUES (9999);

#Añadir la PK a la tabla data_user. Primero buscamos el nombre de la FK para poder borrarla
show create table data_user; 

#Hay que eliminar la FK a Pk de data_user
ALTER TABLE data_user
DROP FOREIGN KEY data_user_ibfk_1;

#Añadimos la FK a la tabla transaction
ALTER TABLE transaction
ADD CONSTRAINT transaction_data_user
FOREIGN KEY (user_id)
REFERENCES data_user(id);

#Nivel 3
#Ejercicio 2

#Id trans, nombre, apellido, IBAN, nomcompañia, 
CREATE VIEW InformeTecnico AS
SELECT transaction.id AS Id_transaction, data_user.name AS Nom, data_user.surname AS Cognom, credit_card.iban AS IBAN, company.company_name AS Companyia
FROM transaction
INNER JOIN data_user ON transaction.user_id = data_user.id
INNER JOIN credit_card ON transaction.credit_card_id = credit_card.id
INNER JOIN company ON transaction.company_id = company.id;

#Muestra los resultados ordenando por ID de transaction
SELECT * 
FROM InformeTecnico
ORDER BY Id_transaction DESC;
