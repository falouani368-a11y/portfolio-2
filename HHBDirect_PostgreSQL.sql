--
-- PostgreSQL database dump
--

\restrict 9L9We3gtvoeUaP6mMtyKxrh3t5Scq6q7TUkgCAsGC0HPA3kgeBnPjtPuFJ73DuD

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: ajouter_client(character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ajouter_client(p_nom character varying, p_prenom character varying, p_adresse character varying, p_identifiant character varying, p_mdp character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    nouveau_num INTEGER;
BEGIN
    SELECT COALESCE(MAX(num_client), 0) + 1
    INTO nouveau_num
    FROM client;

    INSERT INTO client(
        num_client,
        nom_client,
        prenom_client,
        adresse_client,
        identifiant_internet,
        mdp_internet
    )
    VALUES (
        nouveau_num,
        p_nom,
        p_prenom,
        p_adresse,
        p_identifiant,
        p_mdp
    );

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$;


ALTER FUNCTION public.ajouter_client(p_nom character varying, p_prenom character varying, p_adresse character varying, p_identifiant character varying, p_mdp character varying) OWNER TO postgres;

--
-- Name: ajouterclient(character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ajouterclient(nom character varying, prenom character varying, adresse character varying, identifiant character varying, mot_de_passe character varying) RETURNS boolean
    LANGUAGE plpgsql
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
$$;


ALTER FUNCTION public.ajouterclient(nom character varying, prenom character varying, adresse character varying, identifiant character varying, mot_de_passe character varying) OWNER TO postgres;

--
-- Name: calculer_longueur_max(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculer_longueur_max(chaine1 character varying, chaine2 character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    longueur1 INTEGER;
    longueur2 INTEGER;
BEGIN
    longueur1 := LENGTH(chaine1);
    longueur2 := LENGTH(chaine2);

    IF longueur1 > longueur2 THEN
        RETURN longueur1;
    ELSE
        RETURN longueur2;
    END IF;
END;
$$;


ALTER FUNCTION public.calculer_longueur_max(chaine1 character varying, chaine2 character varying) OWNER TO postgres;

--
-- Name: creer_date(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.creer_date(p_mois integer, p_annee integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    date_courante DATE;
    date_fin DATE;
    nb_dates INTEGER := 0;
BEGIN
    date_courante := MAKE_DATE(p_annee, p_mois, 1);
    date_fin := (date_courante + INTERVAL '1 month - 1 day')::DATE;

    WHILE date_courante <= date_fin LOOP

        INSERT INTO date(date)
        VALUES (date_courante)
        ON CONFLICT (date) DO NOTHING;

        IF FOUND THEN
            nb_dates := nb_dates + 1;
        END IF;

        date_courante := date_courante + 1;
    END LOOP;

    RETURN nb_dates;
END;
$$;


ALTER FUNCTION public.creer_date(p_mois integer, p_annee integer) OWNER TO postgres;

--
-- Name: creer_id_internet(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.creer_id_internet(p_nom character varying, p_prenom character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    identifiant VARCHAR;
    nb_clients INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO nb_clients
    FROM client
    WHERE UPPER(nom_client) = UPPER(p_nom)
      AND UPPER(prenom_client) = UPPER(p_prenom);

    identifiant := UPPER(LEFT(p_prenom, 1))
                   || LOWER(p_nom);

    IF nb_clients > 0 THEN
        identifiant := identifiant || nb_clients;
    END IF;

    RETURN identifiant;
END;
$$;


ALTER FUNCTION public.creer_id_internet(p_nom character varying, p_prenom character varying) OWNER TO postgres;

--
-- Name: datesqltodatefr(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.datesqltodatefr(date_param date) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN

    RETURN TO_CHAR(date_param, 'DD/MM/YY');

END;
$$;


ALTER FUNCTION public.datesqltodatefr(date_param date) OWNER TO postgres;

--
-- Name: getnbjoursparmois(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getnbjoursparmois(date_param date) RETURNS integer
    LANGUAGE plpgsql
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
$$;


ALTER FUNCTION public.getnbjoursparmois(date_param date) OWNER TO postgres;

--
-- Name: getnomjour(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getnomjour(date_param date) RETURNS character varying
    LANGUAGE plpgsql
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
$$;


ALTER FUNCTION public.getnomjour(date_param date) OWNER TO postgres;

--
-- Name: getonetuple(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getonetuple() RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE
    res record;
BEGIN
    SELECT INTO res * FROM client;
    RETURN res;
END;
$$;


ALTER FUNCTION public.getonetuple() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: client; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.client (
    num_client integer NOT NULL,
    nom_client character varying(30),
    prenom_client character varying(30),
    adresse_client character varying(192),
    identifiant_internet character varying(30),
    mdp_internet character varying(30)
);


ALTER TABLE public.client OWNER TO postgres;

--
-- Name: getonetupletable(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getonetupletable() RETURNS SETOF public.client
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM client;
END;
$$;


ALTER FUNCTION public.getonetupletable() OWNER TO postgres;

--
-- Name: lesclients(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.lesclients() RETURNS SETOF public.client
    LANGUAGE plpgsql
    AS $$
DECLARE
    res client%ROWTYPE;
BEGIN
    FOR res IN SELECT * FROM client
    LOOP
        RETURN NEXT res;
    END LOOP;
    RETURN;
END;
$$;


ALTER FUNCTION public.lesclients() OWNER TO postgres;

--
-- Name: nb_clients_debiteurs(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.nb_clients_debiteurs() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    resultat INTEGER;
BEGIN
    SELECT COUNT(DISTINCT p.num_client)
    INTO resultat
    FROM posseder p
    JOIN compte c
        ON p.id_type = c.id_type
        AND p.num_compte = c.num_compte
    WHERE c.solde < 0;

    RETURN resultat;
END;
$$;


ALTER FUNCTION public.nb_clients_debiteurs() OWNER TO postgres;

--
-- Name: nb_clients_ville(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.nb_clients_ville(ville character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    resultat INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO resultat
    FROM client
    WHERE adresse_client ILIKE '%' || ville || '%';

    RETURN resultat;
END;
$$;


ALTER FUNCTION public.nb_clients_ville(ville character varying) OWNER TO postgres;

--
-- Name: nb_occurrences_for(character, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.nb_occurrences_for(caractere character, chaine character varying, debut_intervalle integer, fin_intervalle integer) RETURNS integer
    LANGUAGE plpgsql
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
$$;


ALTER FUNCTION public.nb_occurrences_for(caractere character, chaine character varying, debut_intervalle integer, fin_intervalle integer) OWNER TO postgres;

--
-- Name: nb_occurrences_loop(character, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.nb_occurrences_loop(caractere character, chaine character varying, debut_intervalle integer, fin_intervalle integer) RETURNS integer
    LANGUAGE plpgsql
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
$$;


ALTER FUNCTION public.nb_occurrences_loop(caractere character, chaine character varying, debut_intervalle integer, fin_intervalle integer) OWNER TO postgres;

--
-- Name: nb_occurrences_while(character, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.nb_occurrences_while(caractere character, chaine character varying, debut_intervalle integer, fin_intervalle integer) RETURNS integer
    LANGUAGE plpgsql
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
$$;


ALTER FUNCTION public.nb_occurrences_while(caractere character, chaine character varying, debut_intervalle integer, fin_intervalle integer) OWNER TO postgres;

--
-- Name: nb_operation_compte_mois(integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.nb_operation_compte_mois(p_mois integer, p_annee integer, p_num_compte integer, p_id_type integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    resultat INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO resultat
    FROM operation
    WHERE EXTRACT(MONTH FROM date) = p_mois
      AND EXTRACT(YEAR FROM date) = p_annee
      AND (
          (num_compte = p_num_compte AND id_type = p_id_type)
          OR
          (num_compte_vers = p_num_compte AND id_type_vers = p_id_type)
      );

    RETURN resultat;
END;
$$;


ALTER FUNCTION public.nb_operation_compte_mois(p_mois integer, p_annee integer, p_num_compte integer, p_id_type integer) OWNER TO postgres;

--
-- Name: nbclientsdebiteurs(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.nbclientsdebiteurs() RETURNS integer
    LANGUAGE plpgsql
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
$$;


ALTER FUNCTION public.nbclientsdebiteurs() OWNER TO postgres;

--
-- Name: nbclientsville(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.nbclientsville(ville character varying) RETURNS integer
    LANGUAGE plpgsql
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
$$;


ALTER FUNCTION public.nbclientsville(ville character varying) OWNER TO postgres;

--
-- Name: affecter; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.affecter (
    num_client integer NOT NULL,
    date date NOT NULL,
    num_agence integer
);


ALTER TABLE public.affecter OWNER TO postgres;

--
-- Name: agence; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agence (
    num_agence integer NOT NULL,
    nom_agence character varying(50),
    adresse_agence character varying(192),
    tel_agence character(10)
);


ALTER TABLE public.agence OWNER TO postgres;

--
-- Name: compte; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compte (
    id_type smallint NOT NULL,
    num_compte integer NOT NULL,
    date_fermer date,
    date_ouvrir date NOT NULL,
    solde integer
);


ALTER TABLE public.compte OWNER TO postgres;

--
-- Name: date; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.date (
    date date NOT NULL
);


ALTER TABLE public.date OWNER TO postgres;

--
-- Name: operation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.operation (
    id_operation bigint NOT NULL,
    num_compte integer NOT NULL,
    date date NOT NULL,
    id_type smallint NOT NULL,
    id_type_vers smallint,
    num_compte_vers integer,
    designation character varying(50),
    type_operation character varying(20),
    montant integer
);


ALTER TABLE public.operation OWNER TO postgres;

--
-- Name: posseder; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.posseder (
    num_client integer NOT NULL,
    id_type smallint NOT NULL,
    num_compte integer NOT NULL
);


ALTER TABLE public.posseder OWNER TO postgres;

--
-- Name: remunerer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.remunerer (
    date date NOT NULL,
    date_de date NOT NULL,
    id_type smallint NOT NULL,
    taux_interet integer
);


ALTER TABLE public.remunerer OWNER TO postgres;

--
-- Name: type_compte; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.type_compte (
    id_type smallint NOT NULL,
    designation character varying(50)
);


ALTER TABLE public.type_compte OWNER TO postgres;

--
-- Data for Name: affecter; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.affecter (num_client, date, num_agence) FROM stdin;
1	2012-10-27	3
3	2012-11-01	1
3	2012-11-03	\N
2	2012-11-02	3
4	2012-11-01	2
5	2012-11-02	\N
\.


--
-- Data for Name: agence; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.agence (num_agence, nom_agence, adresse_agence, tel_agence) FROM stdin;
1	CAEN Centre	13 Rue St Pierre, 14000 CAEN	0233456789
3	Lannion	2 bis Rue de Brelevenez, 22300 LANNION	0232564345
2	Nogent sur Marne	12 Bd de Strasbourg, 94230 Nogent sur Marne	0145232356
\.


--
-- Data for Name: client; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.client (num_client, nom_client, prenom_client, adresse_client, identifiant_internet, mdp_internet) FROM stdin;
1	DUPONT	Pierre	5 Rue du Port, 22300 LANNION	Pdupont	Pdupont
2	DUPONT	Annie	5 Rue du Port, 22300 LANNION	Adupont	Adupont
3	DELAVAL	Jean	12 Bd de l'Orne, 14234 OUISTREHAM	Jdelaval	Jdelaval
4	HANOT	Eric	13 Avenue de Neuilly, 94230 NOGENT SUR MARNE	Ehanot	Ehanot
5	LEVY	Sarah	1 Rue Neuve, 14110 CONDE SUR NOIREAU	Slevy	Slevy
6	MARTIN	Lucas	10 Rue de Test, 05000 GAP	lucas.martin	test123
7	MARTIN	Lucas	10 Rue de Test, 05000 GAP	lucas.martin	test123
8	MARTIN	Lucas	10 Rue de Test, 05000 GAP	lucas.martin	test123
9	TEST	Lucas	10 Rue de Test, 05000 GAP	Ltest	Ltest
\.


--
-- Data for Name: compte; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compte (id_type, num_compte, date_fermer, date_ouvrir, solde) FROM stdin;
1	1	\N	2012-10-27	1000
2	1	\N	2012-11-01	2000
1	3	\N	2012-11-02	3400
1	4	\N	2012-11-01	4000
1	5	\N	2012-10-27	-1200
2	5	\N	2012-10-27	500
\.


--
-- Data for Name: date; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.date (date) FROM stdin;
2012-10-27
2012-11-01
2012-11-02
2012-11-03
2012-01-01
2012-12-31
2013-02-01
2013-02-02
2013-02-03
2013-02-04
2013-02-05
2013-02-06
2013-02-07
2013-02-08
2013-02-09
2013-02-10
2013-02-11
2013-02-12
2013-02-13
2013-02-14
2013-02-15
2013-02-16
2013-02-17
2013-02-18
2013-02-19
2013-02-20
2013-02-21
2013-02-22
2013-02-23
2013-02-24
2013-02-25
2013-02-26
2013-02-27
2013-02-28
\.


--
-- Data for Name: operation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.operation (id_operation, num_compte, date, id_type, id_type_vers, num_compte_vers, designation, type_operation, montant) FROM stdin;
1	1	2012-10-27	1	\N	\N	Ouverture compte	CREDIT	100
2	1	2012-11-01	1	\N	\N	Versement	CREDIT	900
3	1	2012-11-01	2	\N	\N	Versement Ouverture	CREDIT	2000
4	3	2012-11-02	1	\N	\N	Paye Novembre	CREDIT	5000
5	3	2012-11-03	1	\N	\N	Loyer Novembre	DEBIT	1200
6	3	2012-11-03	1	\N	\N	EDF	DEBIT	400
7	4	2012-11-01	1	\N	\N	Paye Novembre 2012	CREDIT	3500
8	4	2012-11-01	1	\N	\N	Pension	CREDIT	1000
9	4	2012-11-02	1	\N	\N	Rbt CREDIT immobilier	DEBIT	500
10	5	2012-10-27	1	\N	\N	Paye	CREDIT	2500
11	5	2012-10-27	1	2	5	Virement	VIREMENT	500
12	5	2012-11-01	1	\N	\N	Remboursement	DEBIT	3200
\.


--
-- Data for Name: posseder; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.posseder (num_client, id_type, num_compte) FROM stdin;
1	1	1
1	2	1
2	1	1
3	1	3
4	1	4
5	1	5
5	2	5
\.


--
-- Data for Name: remunerer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.remunerer (date, date_de, id_type, taux_interet) FROM stdin;
2012-11-01	2012-01-01	2	2
2012-12-31	2012-11-02	2	4
\.


--
-- Data for Name: type_compte; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.type_compte (id_type, designation) FROM stdin;
1	Compte Courant
2	Livret A
\.


--
-- Name: affecter pk_affecter; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.affecter
    ADD CONSTRAINT pk_affecter PRIMARY KEY (num_client, date);


--
-- Name: agence pk_agence; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agence
    ADD CONSTRAINT pk_agence PRIMARY KEY (num_agence);


--
-- Name: client pk_client; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT pk_client PRIMARY KEY (num_client);


--
-- Name: compte pk_compte; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compte
    ADD CONSTRAINT pk_compte PRIMARY KEY (id_type, num_compte);


--
-- Name: date pk_date; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.date
    ADD CONSTRAINT pk_date PRIMARY KEY (date);


--
-- Name: operation pk_operation; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.operation
    ADD CONSTRAINT pk_operation PRIMARY KEY (id_operation);


--
-- Name: posseder pk_posseder; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posseder
    ADD CONSTRAINT pk_posseder PRIMARY KEY (num_client, id_type, num_compte);


--
-- Name: remunerer pk_remunerer; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.remunerer
    ADD CONSTRAINT pk_remunerer PRIMARY KEY (date, date_de, id_type);


--
-- Name: type_compte pk_type_compte; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_compte
    ADD CONSTRAINT pk_type_compte PRIMARY KEY (id_type);


--
-- Name: i_fk_affecter_agence; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX i_fk_affecter_agence ON public.affecter USING btree (num_agence);


--
-- Name: i_fk_affecter_client; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX i_fk_affecter_client ON public.affecter USING btree (num_client);


--
-- Name: i_fk_affecter_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX i_fk_affecter_date ON public.affecter USING btree (date);


--
-- Name: i_fk_compte_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX i_fk_compte_date ON public.compte USING btree (date_fermer);


--
-- Name: i_fk_compte_date2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX i_fk_compte_date2 ON public.compte USING btree (date_ouvrir);


--
-- Name: i_fk_compte_type_compte; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX i_fk_compte_type_compte ON public.compte USING btree (id_type);


--
-- Name: i_fk_operation_compte; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX i_fk_operation_compte ON public.operation USING btree (id_type, num_compte);


--
-- Name: i_fk_operation_compte1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX i_fk_operation_compte1 ON public.operation USING btree (id_type_vers, num_compte_vers);


--
-- Name: i_fk_operation_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX i_fk_operation_date ON public.operation USING btree (date);


--
-- Name: i_fk_posseder_client; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX i_fk_posseder_client ON public.posseder USING btree (num_client);


--
-- Name: i_fk_posseder_compte; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX i_fk_posseder_compte ON public.posseder USING btree (id_type, num_compte);


--
-- Name: i_fk_remunerer_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX i_fk_remunerer_date ON public.remunerer USING btree (date);


--
-- Name: i_fk_remunerer_date1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX i_fk_remunerer_date1 ON public.remunerer USING btree (date_de);


--
-- Name: i_fk_remunerer_type_compte; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX i_fk_remunerer_type_compte ON public.remunerer USING btree (id_type);


--
-- Name: affecter fk_affecter_agence; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.affecter
    ADD CONSTRAINT fk_affecter_agence FOREIGN KEY (num_agence) REFERENCES public.agence(num_agence);


--
-- Name: affecter fk_affecter_client; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.affecter
    ADD CONSTRAINT fk_affecter_client FOREIGN KEY (num_client) REFERENCES public.client(num_client);


--
-- Name: affecter fk_affecter_date; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.affecter
    ADD CONSTRAINT fk_affecter_date FOREIGN KEY (date) REFERENCES public.date(date);


--
-- Name: compte fk_compte_date; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compte
    ADD CONSTRAINT fk_compte_date FOREIGN KEY (date_fermer) REFERENCES public.date(date);


--
-- Name: compte fk_compte_date2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compte
    ADD CONSTRAINT fk_compte_date2 FOREIGN KEY (date_ouvrir) REFERENCES public.date(date);


--
-- Name: compte fk_compte_type_compte; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compte
    ADD CONSTRAINT fk_compte_type_compte FOREIGN KEY (id_type) REFERENCES public.type_compte(id_type);


--
-- Name: operation fk_operation_compte; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.operation
    ADD CONSTRAINT fk_operation_compte FOREIGN KEY (id_type, num_compte) REFERENCES public.compte(id_type, num_compte);


--
-- Name: operation fk_operation_compte1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.operation
    ADD CONSTRAINT fk_operation_compte1 FOREIGN KEY (id_type_vers, num_compte_vers) REFERENCES public.compte(id_type, num_compte);


--
-- Name: operation fk_operation_date; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.operation
    ADD CONSTRAINT fk_operation_date FOREIGN KEY (date) REFERENCES public.date(date);


--
-- Name: posseder fk_posseder_client; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posseder
    ADD CONSTRAINT fk_posseder_client FOREIGN KEY (num_client) REFERENCES public.client(num_client);


--
-- Name: posseder fk_posseder_compte; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posseder
    ADD CONSTRAINT fk_posseder_compte FOREIGN KEY (id_type, num_compte) REFERENCES public.compte(id_type, num_compte);


--
-- Name: remunerer fk_remunerer_date; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.remunerer
    ADD CONSTRAINT fk_remunerer_date FOREIGN KEY (date) REFERENCES public.date(date);


--
-- Name: remunerer fk_remunerer_date1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.remunerer
    ADD CONSTRAINT fk_remunerer_date1 FOREIGN KEY (date_de) REFERENCES public.date(date);


--
-- Name: remunerer fk_remunerer_type_compte; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.remunerer
    ADD CONSTRAINT fk_remunerer_type_compte FOREIGN KEY (id_type) REFERENCES public.type_compte(id_type);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict 9L9We3gtvoeUaP6mMtyKxrh3t5Scq6q7TUkgCAsGC0HPA3kgeBnPjtPuFJ73DuD

