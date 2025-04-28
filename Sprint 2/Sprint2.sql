SELECT *
FROM company; 

SELECT *
FROM transaction; 

##NIVELL 1

#EXERCICI 2 

#LLISTAT DELS PAISOS QUE ESTAN FENT COMPRES
SELECT 
    country AS Països_compres
FROM
    transaction
        INNER JOIN
    company ON transaction.company_id = company.id
GROUP BY country
ORDER BY country ASC;

#Des de quants països es realitzen les compres
SELECT 
    COUNT(DISTINCT company.country) AS total_països
FROM
    company
        INNER JOIN
    transaction ON transaction.company_id = company.id;

#Identifica la companyia amb la mitjana més gran de vendes. 
SELECT 
    company_name, AVG(amount) AS mitja_vendes
FROM
    company
        INNER JOIN
    transaction ON company.id = transaction.company_id
GROUP BY company_name
ORDER BY mitja_vendes DESC
LIMIT 1;

#EXERCICI 3

#Mostra totes les transaccions realitzades per empreses d'Alemanya.  
SELECT 
    *
FROM
    transaction
WHERE
    company_id IN (SELECT 
            id
        FROM
            company
        WHERE
            country LIKE 'Germany');

#Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions. 
SELECT 
    *
FROM
    company
WHERE
    id IN (SELECT 
            company_id
        FROM
            transaction
        WHERE
            amount > (SELECT 
                    AVG(amount)
                FROM
                    transaction));

#Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses. 
SELECT 
    company_name
FROM
    company
WHERE
    NOT EXISTS( SELECT 
            *
        FROM
            transaction);
            
## NIVELL 2

#EXERCICI 1
#Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
#Mostra la data de cada transacció juntament amb el total de les vendes. 
SELECT 
    DATE(timestamp) AS dia, SUM(amount) AS total_vendes
FROM
    transaction
WHERE
    declined LIKE 0
GROUP BY DATE(timestamp)
ORDER BY total_vendes DESC
LIMIT 5;

#EXERCICI 2
#Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà. 
SELECT 
    country, AVG(amount) AS mitjana_vendes
FROM
    company
        INNER JOIN
    transaction ON company.id = transaction.company_id
GROUP BY country
ORDER BY mitjana_vendes DESC;

#EXERCICI 3
#En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute".
#Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia. 

#Mostra el llistat aplicant JOIN i subconsultes. 
SELECT 
	*
FROM
    transaction
        INNER JOIN
    company ON transaction.company_id = company.id
WHERE
    country IN (SELECT 
            country
        FROM
            company
        WHERE
            company_name LIKE '%non%Institute%');

#Mostra el llistat aplicant solament subconsultes. 
SELECT 
    *
FROM
    transaction
WHERE
    company_id IN (SELECT 
            id
        FROM
            company
        WHERE
            country IN (SELECT 
                    country
                FROM
                    company
                WHERE
                    company_name LIKE '%non%Institute%'));
                    
# NIVELL 3

#EXERCICI 1
#Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros 
# i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat. 

SELECT 
    company_name, phone, country, DATE(timestamp), amount
FROM
    company
        INNER JOIN
    transaction ON company.id = transaction.company_id
WHERE
    amount BETWEEN 100 AND 200
        AND DATE(timestamp) IN ('2021-04-29' , '2021-07-20', '2022-03-13')
ORDER BY amount DESC;

#EXERCICI 2
#Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen la informació 
#sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent 
# i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys. 

SELECT 
    company_name,
    COUNT(transaction.id) AS num_transaccions,
    CASE
        WHEN COUNT(transaction.id) > 4 THEN 'Més de 4'
        ELSE 'Menys de 4'
    END AS classificacio
FROM
    company
        LEFT JOIN
    transaction ON company.id = transaction.company_id
GROUP BY company.id , company.company_name;
