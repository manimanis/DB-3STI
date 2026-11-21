-- ============================================================================
-- DEVOIR DE CONTRÔLE N°1 (SUJET B) : Service « VoltRide »
-- Base de données : voltride_db (MariaDB / MySQL - phpMyAdmin)
-- ============================================================================

DROP DATABASE IF EXISTS voltride_db;
CREATE DATABASE voltride_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE voltride_db;

-- ----------------------------------------------------------------------------
-- EXERCICE 3 : LDD — Création des tables et évolutions ALTER TABLE
-- ----------------------------------------------------------------------------

-- Table mère fournie dans l'énoncé
CREATE TABLE Abonne (
    idAb  INT AUTO_INCREMENT,
    nomAb VARCHAR(40) NOT NULL,
    telAb VARCHAR(15) NOT NULL,
    ville VARCHAR(30) NOT NULL,
    CONSTRAINT pk_abonne PRIMARY KEY (idAb)
);

-- Q1 : Création de Trottinette
CREATE TABLE Trottinette (
    codeTrot  VARCHAR(6),
    modele    VARCHAR(40) NOT NULL,
    categorie ENUM('Urbaine', 'Tout-terrain') NOT NULL,
    tarifH    DECIMAL(7,3) NOT NULL,
    CONSTRAINT pk_trottinette PRIMARY KEY (codeTrot),
    CONSTRAINT chk_tarif_trot CHECK (tarifH > 0)
);

-- Q2 : Création de Location
CREATE TABLE Location (
    numLoc   INT AUTO_INCREMENT,
    dateLoc  DATE NOT NULL,
    heureDeb INT  NOT NULL,
    dureeH   INT  NOT NULL DEFAULT 1,
    codeTrot VARCHAR(6) NOT NULL,
    idAb     INT        NOT NULL,
    CONSTRAINT pk_location   PRIMARY KEY (numLoc),
    CONSTRAINT chk_duree_loc CHECK (dureeH BETWEEN 1 AND 4),
    CONSTRAINT fk_loc_trot   FOREIGN KEY (codeTrot)
        REFERENCES Trottinette(codeTrot)
        ON DELETE RESTRICT,
    CONSTRAINT fk_loc_ab     FOREIGN KEY (idAb)
        REFERENCES Abonne(idAb)
        ON DELETE CASCADE
);

-- Q3 : Évolutions ALTER TABLE
ALTER TABLE Abonne      ADD cinAb VARCHAR(8) NULL UNIQUE;
ALTER TABLE Trottinette MODIFY modele VARCHAR(60) NOT NULL;
ALTER TABLE Abonne      CHANGE telAb numTel VARCHAR(20) NOT NULL;

-- ----------------------------------------------------------------------------
-- EXERCICE 4 : LMD — Insertions, mise à jour et suppression
-- ----------------------------------------------------------------------------

-- Q1 : Insertion multiple dans Trottinette
INSERT INTO Trottinette (codeTrot, modele, categorie, tarifH) VALUES
('TR01', 'Xiaomi Pro 2',  'Urbaine',      12.000),
('TR02', 'Dualtron Mini', 'Tout-terrain', 18.500);

-- Q2 : Insertion simple dans Abonne (idAb = 1)
INSERT INTO Abonne (nomAb, numTel, ville, cinAb)
VALUES ('Sami Khelil', '55443322', 'Sousse', NULL);

-- Données de test dans Location (dont numLoc = 24 pour tester Q4 et Q5)
INSERT INTO Location (numLoc, dateLoc, heureDeb, dureeH, codeTrot, idAb) VALUES
(1,  '2026-11-25', 14, 2, 'TR01', 1),
(2,  '2026-11-26', 16, 3, 'TR01', 1),
(24, '2026-11-28', 15, 1, 'TR02', 1);

-- Q3 : Remise de 2 DT pour les trottinettes Tout-terrain (TR02 passe à 16.500 DT)
UPDATE Trottinette
SET tarifH = tarifH - 2
WHERE categorie = 'Tout-terrain';

-- Q4 : Suppression de la location n°24
DELETE FROM Location
WHERE numLoc = 24;

-- ----------------------------------------------------------------------------
-- EXERCICE 4 (Q5) : Tests d'intégrité (à décommenter dans l'onglet SQL)
-- ----------------------------------------------------------------------------

/*
-- Test 5a : ON DELETE RESTRICT (refusé : 'TR01' référencée dans Location)
DELETE FROM Trottinette WHERE codeTrot = 'TR01';

-- Test 5b : Violation de la contrainte CHECK (refusé : dureeH = 6 hors [1, 4])
INSERT INTO Location (dateLoc, heureDeb, dureeH, codeTrot, idAb)
VALUES ('2026-12-05', 14, 6, 'TR01', 1);
*/