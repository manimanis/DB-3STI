-- ============================================================================
-- SÉANCE 10 (SUJET B) : Agence d'Excursions « TunisiTrip »
-- Base de données : tunisitrip_db (MariaDB / MySQL - phpMyAdmin)
-- ============================================================================

DROP DATABASE IF EXISTS tunisitrip_db;
CREATE DATABASE tunisitrip_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE tunisitrip_db;

-- ----------------------------------------------------------------------------
-- PARTIE 2 : LDD — Création des tables et contraintes
-- ----------------------------------------------------------------------------

CREATE TABLE Guide (
    idGuide  INT AUTO_INCREMENT,
    nomGuide VARCHAR(40) NOT NULL,
    langue   VARCHAR(30) NOT NULL,
    tel      VARCHAR(15) NOT NULL,
    CONSTRAINT pk_guide     PRIMARY KEY (idGuide),
    CONSTRAINT uq_guide_tel UNIQUE (tel)
);

CREATE TABLE Voyageur (
    idVoy     INT AUTO_INCREMENT,
    nom       VARCHAR(40) NOT NULL,
    prenom    VARCHAR(40) NOT NULL,
    ville     VARCHAR(30) NOT NULL,
    tel       VARCHAR(15) NULL,
    dateNaiss DATE        NOT NULL,
    CONSTRAINT pk_voyageur PRIMARY KEY (idVoy)
);

CREATE TABLE Excursion (
    codeExc     VARCHAR(10),
    titre       VARCHAR(50)  NOT NULL,
    destination VARCHAR(30)  NOT NULL,
    prixPers    DECIMAL(8,3) NOT NULL,
    idGuide     INT          NOT NULL,
    CONSTRAINT pk_excursion   PRIMARY KEY (codeExc),
    CONSTRAINT chk_prix_pers  CHECK (prixPers > 0),
    CONSTRAINT fk_exc_guide   FOREIGN KEY (idGuide)
        REFERENCES Guide(idGuide)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE Reservation (
    idVoy    INT,
    codeExc  VARCHAR(10),
    dateRes  DATE NOT NULL,
    nbPlaces INT  NOT NULL DEFAULT 1,
    CONSTRAINT pk_res        PRIMARY KEY (idVoy, codeExc),
    CONSTRAINT chk_nb_places CHECK (nbPlaces BETWEEN 1 AND 10),
    CONSTRAINT fk_res_voy    FOREIGN KEY (idVoy)
        REFERENCES Voyageur(idVoy)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_res_exc    FOREIGN KEY (codeExc)
        REFERENCES Excursion(codeExc)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Évolutions de structure (Partie 2 - Question 5)
ALTER TABLE Voyageur  ADD email VARCHAR(80) NULL UNIQUE;
ALTER TABLE Excursion MODIFY destination VARCHAR(50) NOT NULL;

-- ----------------------------------------------------------------------------
-- PEUPLEMENT INITIAL : Jeu de données de référence
-- ----------------------------------------------------------------------------

INSERT INTO Guide (nomGuide, langue, tel) VALUES
('Ben Amor', 'Français', '22110022'),
('Sassi',    'Anglais',  '55330044'),
('Mabrouk',  'Italien',  '98550066');

INSERT INTO Excursion (codeExc, titre, destination, prixPers, idGuide) VALUES
('EXC01', 'Désert et Oasis', 'Tozeur',   180.000, 1),
('EXC02', 'Circuit Médina',  'Kairouan',  95.000, 1),
('EXC03', 'Plongée et Mer',  'Tabarka',  140.000, 2),
('EXC04', 'Dunes du Sud',    'Douz',     160.000, 3),
('EXC05', 'Croisière Île',   'Djerba',   210.000, 2);

INSERT INTO Voyageur (nom, prenom, ville, tel, dateNaiss) VALUES
('Gharbi',   'Adam',    'Sousse', '22887766', '2008-04-12'),
('Trabelsi', 'Nour',    'Tunis',  '55998877', '2007-09-25'),
('Khelifi',  'Rayen',   'Sousse', NULL,       '2009-01-18'),
('Jaziri',   'Ines',    'Sfax',   '98223344', '2008-06-05'),
('Mansouri', 'Fares',   'Sousse', '29445566', '2007-12-03'),
('Bouazizi', 'Yasmine', 'Tunis',  '50667788', '2009-03-22');

INSERT INTO Reservation (idVoy, codeExc, dateRes, nbPlaces) VALUES
(1, 'EXC01', '2026-01-15', 2),
(1, 'EXC03', '2026-02-10', 1),
(2, 'EXC04', '2026-01-22', 4),
(3, 'EXC01', '2026-02-18', 1),
(3, 'EXC02', '2026-03-05', 3),
(4, 'EXC05', '2026-03-20', 2),
(5, 'EXC01', '2026-04-08', 3),
(5, 'EXC04', '2026-04-14', 2);

-- ----------------------------------------------------------------------------
-- PARTIE 4 : Requêtes SELECT de vérification (à décommenter / tester sous phpMyAdmin)
-- ----------------------------------------------------------------------------

/*
-- Q1 : Voyageurs de Sousse sans téléphone (1 ligne : Rayen Khelifi)
SELECT idVoy, nom, prenom
FROM Voyageur
WHERE ville = 'Sousse' AND tel IS NULL;

-- Q2 : Excursions entre 100 et 200 DT contenant Désert ou Dunes (EXC01, EXC04)
SELECT codeExc, titre, prixPers
FROM Excursion
WHERE prixPers BETWEEN 100 AND 200
  AND (titre LIKE '%Désert%' OR titre LIKE '%Dunes%')
ORDER BY prixPers DESC;

-- Q3 : Nom complet formaté et année de naissance 2008/2009 (4 lignes)
SELECT CONCAT(UPPER(nom), ' ', prenom) AS Voyageur,
       YEAR(dateNaiss) AS Annee_Naiss
FROM Voyageur
WHERE YEAR(dateNaiss) IN (2008, 2009);

-- Q4 : Villes comptant au moins 2 voyageurs (Sousse: 3, Tunis: 2)
SELECT ville, COUNT(*) AS Nb_Voyageurs
FROM Voyageur
GROUP BY ville
HAVING COUNT(*) >= 2
ORDER BY Nb_Voyageurs DESC;

-- Q5 : Jointure implicite 2 tables : Excursion + Guide (5 lignes)
SELECT E.titre, E.destination, E.prixPers, G.nomGuide, G.langue
FROM Excursion E, Guide G
WHERE E.idGuide = G.idGuide
ORDER BY G.nomGuide ASC;

-- Q6 : Jointure implicite 3 tables : T1 2026 + montant payé (6 lignes)
SELECT V.nom, V.prenom, E.titre, R.dateRes, R.nbPlaces,
       (E.prixPers * R.nbPlaces) AS Montant_DT
FROM Voyageur V, Reservation R, Excursion E
WHERE V.idVoy = R.idVoy
  AND R.codeExc = E.codeExc
  AND YEAR(R.dateRes) = 2026
  AND MONTH(R.dateRes) IN (1, 2, 3);

-- Q7 : Jointure + GROUP BY : Recette par excursion (EXC01: 1080 DT, EXC04: 960 DT, EXC05: 420 DT, EXC02: 285 DT, EXC03: 140 DT)
SELECT E.codeExc, E.titre,
       COUNT(*) AS Nb_Res,
       SUM(E.prixPers * R.nbPlaces) AS Recette_DT
FROM Excursion E, Reservation R
WHERE E.codeExc = R.codeExc
GROUP BY E.codeExc, E.titre
ORDER BY Recette_DT DESC;

-- Q8 : CA par guide auprès des voyageurs de Sousse > 500 DT (Ben Amor : 1365.000 DT)
SELECT G.nomGuide,
       SUM(E.prixPers * R.nbPlaces) AS CA_Sousse
FROM Guide G, Excursion E, Reservation R, Voyageur V
WHERE G.idGuide = E.idGuide
  AND E.codeExc = R.codeExc
  AND R.idVoy = V.idVoy
  AND V.ville = 'Sousse'
GROUP BY G.idGuide, G.nomGuide
HAVING SUM(E.prixPers * R.nbPlaces) > 500;
*/

