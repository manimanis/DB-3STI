-- ============================================================================
-- SÉANCE 10 (SUJET A) : Club Sportif « FitZone »
-- Base de données : fitzone_db (MariaDB / MySQL - phpMyAdmin)
-- ============================================================================

DROP DATABASE IF EXISTS fitzone_db;
CREATE DATABASE fitzone_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE fitzone_db;

-- ----------------------------------------------------------------------------
-- PARTIE 2 : LDD — Création des tables et contraintes
-- ----------------------------------------------------------------------------

CREATE TABLE Coach (
    idCoach    INT AUTO_INCREMENT,
    nomCoach   VARCHAR(40) NOT NULL,
    specialite VARCHAR(30) NOT NULL,
    tel        VARCHAR(15) NOT NULL,
    CONSTRAINT pk_coach     PRIMARY KEY (idCoach),
    CONSTRAINT uq_coach_tel UNIQUE (tel)
);

CREATE TABLE Adherent (
    idAdh     INT AUTO_INCREMENT,
    nom       VARCHAR(40) NOT NULL,
    prenom    VARCHAR(40) NOT NULL,
    ville     VARCHAR(30) NOT NULL,
    tel       VARCHAR(15) NULL,
    dateNaiss DATE        NOT NULL,
    CONSTRAINT pk_adherent PRIMARY KEY (idAdh)
);

CREATE TABLE Activite (
    codeAct   VARCHAR(10),
    libelle   VARCHAR(50)  NOT NULL,
    salle     VARCHAR(20)  NOT NULL,
    tarifMois DECIMAL(8,3) NOT NULL,
    idCoach   INT          NOT NULL,
    CONSTRAINT pk_activite  PRIMARY KEY (codeAct),
    CONSTRAINT chk_tarif    CHECK (tarifMois > 0),
    CONSTRAINT fk_act_coach FOREIGN KEY (idCoach)
        REFERENCES Coach(idCoach)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE Inscription (
    idAdh     INT,
    codeAct   VARCHAR(10),
    dateInscr DATE NOT NULL,
    nbMois    INT  NOT NULL DEFAULT 1,
    CONSTRAINT pk_inscr     PRIMARY KEY (idAdh, codeAct),
    CONSTRAINT chk_nb_mois  CHECK (nbMois BETWEEN 1 AND 12),
    CONSTRAINT fk_inscr_adh FOREIGN KEY (idAdh)
        REFERENCES Adherent(idAdh)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_inscr_act FOREIGN KEY (codeAct)
        REFERENCES Activite(codeAct)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Évolutions de structure (Partie 2 - Question 5)
ALTER TABLE Adherent ADD email VARCHAR(80) NULL UNIQUE;
ALTER TABLE Activite MODIFY salle VARCHAR(35) NOT NULL;

-- ----------------------------------------------------------------------------
-- PEUPLEMENT INITIAL : Jeu de données de référence
-- ----------------------------------------------------------------------------

INSERT INTO Coach (nomCoach, specialite, tel) VALUES
('Ben Youssef', 'Musculation',   '22100200'),
('Trabelsi',    'Cardio',        '55300400'),
('Gharbi',      'Arts Martiaux', '98500600');

INSERT INTO Activite (codeAct, libelle, salle, tarifMois, idCoach) VALUES
('ACT01', 'CrossFit Intense',  'Salle A', 120.000, 1),
('ACT02', 'Musculation Libre', 'Salle A',  90.000, 1),
('ACT03', 'Spinning Cardio',   'Salle B',  85.000, 2),
('ACT04', 'Boxe Anglaise',     'Salle C', 110.000, 3),
('ACT05', 'Natation Fitness',  'Piscine', 150.000, 2);

INSERT INTO Adherent (nom, prenom, ville, tel, dateNaiss) VALUES
('Khelifi',  'Youssef', 'Sousse',   '22445566', '2008-05-14'),
('Mansouri', 'Meriem',  'Tunis',    '55778899', '2007-11-02'),
('Jaziri',   'Amine',   'Sousse',   NULL,       '2009-02-20'),
('Bouazizi', 'Sarra',   'Monastir', '98112233', '2008-08-30'),
('Ben Ali',  'Rami',    'Sousse',   '29667788', '2007-03-10'),
('Chaabane', 'Lina',    'Tunis',    '50334455', '2009-07-19');

INSERT INTO Inscription (idAdh, codeAct, dateInscr, nbMois) VALUES
(1, 'ACT01', '2026-01-10', 3),
(1, 'ACT03', '2026-02-05', 2),
(2, 'ACT04', '2026-01-18', 6),
(3, 'ACT01', '2026-02-12', 1),
(3, 'ACT02', '2026-03-01', 3),
(4, 'ACT05', '2026-03-15', 2),
(5, 'ACT01', '2026-04-02', 4),
(5, 'ACT04', '2026-04-10', 2);

-- ----------------------------------------------------------------------------
-- PARTIE 4 : Requêtes SELECT de vérification (à décommenter / copier dans SQL)
-- ----------------------------------------------------------------------------

/*
-- Q1 : Adhérents de Sousse sans téléphone (1 ligne : Amine Jaziri)
SELECT idAdh, nom, prenom
FROM Adherent
WHERE ville = 'Sousse' AND tel IS NULL;

-- Q2 : Activités entre 90 et 150 DT contenant Fitness ou Intense (ACT05, ACT01)
SELECT codeAct, libelle, tarifMois
FROM Activite
WHERE tarifMois BETWEEN 90 AND 150
  AND (libelle LIKE '%Fitness%' OR libelle LIKE '%Intense%')
ORDER BY tarifMois DESC;

-- Q3 : Nom complet formaté et année de naissance 2008/2009 (4 lignes)
SELECT CONCAT(UPPER(nom), ' ', prenom) AS Adherent,
       YEAR(dateNaiss) AS Annee_Naiss
FROM Adherent
WHERE YEAR(dateNaiss) IN (2008, 2009);

-- Q4 : Villes comptant au moins 2 adhérents (Sousse: 3, Tunis: 2)
SELECT ville, COUNT(*) AS Nb_Adherents
FROM Adherent
GROUP BY ville
HAVING COUNT(*) >= 2
ORDER BY Nb_Adherents DESC;

-- Q5 : Jointure implicite 2 tables : Activite + Coach (5 lignes)
SELECT Act.libelle, Act.salle, Act.tarifMois, C.nomCoach, C.specialite
FROM Activite Act, Coach C
WHERE Act.idCoach = C.idCoach
ORDER BY C.nomCoach ASC;

-- Q6 : Jointure implicite 3 tables : T1 2026 + montant payé (6 lignes)
SELECT A.nom, A.prenom, Act.libelle, I.dateInscr, I.nbMois,
       (Act.tarifMois * I.nbMois) AS Montant_DT
FROM Adherent A, Inscription I, Activite Act
WHERE A.idAdh = I.idAdh
  AND I.codeAct = Act.codeAct
  AND YEAR(I.dateInscr) = 2026
  AND MONTH(I.dateInscr) IN (1, 2, 3);

-- Q7 : Recette totale par activité (ACT01: 960, ACT04: 880, ACT05: 300, ACT02: 270, ACT03: 170)
SELECT Act.codeAct, Act.libelle,
       COUNT(*) AS Nb_Inscrits,
       SUM(Act.tarifMois * I.nbMois) AS Recette_DT
FROM Activite Act, Inscription I
WHERE Act.codeAct = I.codeAct
GROUP BY Act.codeAct, Act.libelle
ORDER BY Recette_DT DESC;

-- Q8 : CA par coach auprès des adhérents de Sousse > 500 DT (Ben Youssef : 1230.000 DT)
SELECT C.nomCoach,
       SUM(Act.tarifMois * I.nbMois) AS CA_Sousse
FROM Coach C, Activite Act, Inscription I, Adherent A
WHERE C.idCoach = Act.idCoach
  AND Act.codeAct = I.codeAct
  AND I.idAdh = A.idAdh
  AND A.ville = 'Sousse'
GROUP BY C.idCoach, C.nomCoach
HAVING SUM(Act.tarifMois * I.nbMois) > 500;
*/