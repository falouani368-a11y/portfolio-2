CREATE OR REPLACE FUNCTION nb_occurrences_for(
    caractere CHAR,
    chaine VARCHAR,
    debut_intervalle INTEGER,
    fin_intervalle INTEGER
)
RETURNS INTEGER
AS $$
DECLARE
    compteur INTEGER := 0;
    i INTEGER;
BEGIN

    -- Vérification de l'intervalle
    IF debut_intervalle < 1
       OR fin_intervalle > LENGTH(chaine)
       OR debut_intervalle > fin_intervalle THEN
        RETURN -1;
    END IF;

    -- Parcours de l'intervalle avec FOR
    FOR i IN debut_intervalle..fin_intervalle LOOP

        IF SUBSTR(chaine, i, 1) = caractere THEN
            compteur := compteur + 1;
        END IF;

    END LOOP;

    RETURN compteur;

END;
$$ LANGUAGE plpgsql;


-- Test de la fonction FOR
SELECT nb_occurrences_for('a', 'banane', 1, 6);


-- =========================================================
-- EXERCICE 2 - VERSION 2 : BOUCLE LOOP / EXIT
-- =========================================================

CREATE OR REPLACE FUNCTION nb_occurrences_loop(
    caractere CHAR,
    chaine VARCHAR,
    debut_intervalle INTEGER,
    fin_intervalle INTEGER
)
RETURNS INTEGER
AS $$
DECLARE
    compteur INTEGER := 0;
    i INTEGER;
BEGIN

    -- Vérification de l'intervalle
    IF debut_intervalle < 1
       OR fin_intervalle > LENGTH(chaine)
       OR debut_intervalle > fin_intervalle THEN
        RETURN -1;
    END IF;

    i := debut_intervalle;

    LOOP

        IF SUBSTR(chaine, i, 1) = caractere THEN
            compteur := compteur + 1;
        END IF;

        i := i + 1;

        EXIT WHEN i > fin_intervalle;

    END LOOP;

    RETURN compteur;

END;
$$ LANGUAGE plpgsql;


-- Test de la fonction LOOP
SELECT nb_occurrences_loop('a', 'banane', 1, 6);


-- =========================================================
-- EXERCICE 2 - VERSION 3 : BOUCLE WHILE
-- =========================================================

CREATE OR REPLACE FUNCTION nb_occurrences_while(
    caractere CHAR,
    chaine VARCHAR,
    debut_intervalle INTEGER,
    fin_intervalle INTEGER
)
RETURNS INTEGER
AS $$
DECLARE
    compteur INTEGER := 0;
    i INTEGER;
BEGIN

    -- Vérification de l'intervalle
    IF debut_intervalle < 1
       OR fin_intervalle > LENGTH(chaine)
       OR debut_intervalle > fin_intervalle THEN
        RETURN -1;
    END IF;

    i := debut_intervalle;

    WHILE i <= fin_intervalle LOOP

        IF SUBSTR(chaine, i, 1) = caractere THEN
            compteur := compteur + 1;
        END IF;

        i := i + 1;

    END LOOP;

    RETURN compteur;

END;
$$ LANGUAGE plpgsql;


-- Test de la fonction WHILE
SELECT nb_occurrences_while('a', 'banane', 1, 6);

CREATE OR REPLACE FUNCTION getNbJoursParMois(
    date_param DATE
)
RETURNS INTEGER
AS $$
BEGIN

    RETURN EXTRACT(
        DAY FROM (
            DATE_TRUNC('month', date_param)
            + INTERVAL '1 month'
            - INTERVAL '1 day'
        )
    );

END;
$$ LANGUAGE plpgsql;
SELECT getNbJoursParMois('2025-02-15');
CREATE OR REPLACE FUNCTION dateSqlToDatefr(
    date_param DATE
)
RETURNS VARCHAR
AS $$
BEGIN

    RETURN TO_CHAR(date_param, 'DD/MM/YY');

END;
$$ LANGUAGE plpgsql;
SELECT dateSqlToDatefr('2025-09-18');
CREATE OR REPLACE FUNCTION getNomJour(
    date_param DATE
)
RETURNS VARCHAR
AS $$
DECLARE
    numero_jour INTEGER;
BEGIN

    numero_jour := EXTRACT(DOW FROM date_param);

    CASE numero_jour
        WHEN 0 THEN
            RETURN 'Dimanche';

        WHEN 1 THEN
            RETURN 'Lundi';

        WHEN 2 THEN
            RETURN 'Mardi';

        WHEN 3 THEN
            RETURN 'Mercredi';

        WHEN 4 THEN
            RETURN 'Jeudi';

        WHEN 5 THEN
            RETURN 'Vendredi';

        WHEN 6 THEN
            RETURN 'Samedi';
    END CASE;

END;
$$ LANGUAGE plpgsql;
SELECT getNomJour('2025-09-18');
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name IN ('client', 'compte')
ORDER BY table_name, ordinal_position;
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'posseder'
ORDER BY ordinal_position;
SELECT *
FROM compte;
CREATE OR REPLACE FUNCTION nbClientsDebiteurs()
RETURNS INTEGER
AS $$
DECLARE
    nombre INTEGER;
BEGIN

    SELECT COUNT(DISTINCT p.num_client)
    INTO nombre
    FROM posseder p
    JOIN compte c ON p.num_compte = c.num_compte
    WHERE c.solde < 0
      AND DATE_PART('year', c.date_ouvrir) = 2012;

    RETURN nombre;

END;
$$ LANGUAGE plpgsql;
SELECT nbClientsDebiteurs();
SELECT num_client, nom_client, prenom_client, adresse_client
FROM client;
CREATE OR REPLACE FUNCTION nbClientsVille(
    ville VARCHAR
)
RETURNS INTEGER
AS $$
DECLARE
    nombre INTEGER;
BEGIN

    SELECT COUNT(*)
    INTO nombre
    FROM client
    WHERE adresse_client LIKE '%' || ville;

    RETURN nombre;

END;
$$ LANGUAGE plpgsql;

SELECT nbClientsVille('LANNION');




SELECT column_name, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'client'
ORDER BY ordinal_position;



CREATE OR REPLACE FUNCTION ajouterClient(
    nom VARCHAR,
    prenom VARCHAR,
    adresse VARCHAR,
    identifiant VARCHAR,
    mot_de_passe VARCHAR
)
RETURNS BOOLEAN
AS $$
DECLARE
    nouveau_numero INTEGER;
BEGIN

    -- Récupération du dernier numéro de client
    SELECT COALESCE(MAX(num_client), 0) + 1
    INTO nouveau_numero
    FROM client;

    -- Insertion du nouveau client
    INSERT INTO client(
        num_client,
        nom_client,
        prenom_client,
        adresse_client,
        identifiant_internet,
        mdp_internet
    )
    VALUES (
        nouveau_numero,
        nom,
        prenom,
        adresse,
        identifiant,
        mot_de_passe
    );

    RETURN TRUE;

END;
$$ LANGUAGE plpgsql;


SELECT ajouterClient(
    'MARTIN',
    'Lucas',
    '10 Rue de Test, 05000 GAP',
    'lucas.martin',
    'test123'
);
SELECT *
FROM client
ORDER BY num_client DESC
LIMIT 1;



