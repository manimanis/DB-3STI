-- ============================================================================
-- DEVOIR DE CONTRÔLE N°1 (SUJET A) : Complexe « Takwira Arena »
-- Base de données : takwira_db (MariaDB / MySQL - phpMyAdmin)
-- ============================================================================

DROP DATABASE IF EXISTS takwira_db;
CREATE DATABASE takwira_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE takwira_db;

-- ----------------------------------------------------------------------------
-- EXERCICE 3 : LDD — Création des tables et évolutions ALTER TABLE
-- ----------------------------------------------------------------------------

-- Table mère fournie dans l'énoncé
CREATE TABLE Equipe (
    idEq   INT AUTO_INCREMENT,
    nomEq  VARCHAR(40) NOT NULL,
    telCap VARCHAR(15) NOT NULL,
    ville  VARCHAR(30) NOT NULL,
    CONSTRAINT pk_equipe PRIMARY KEY (idEq)
);

-- Q1 : Création de Terrain
CREATE TABLE Terrain (
    codeTer   VARCHAR(5),
    nomTer    VARCHAR(40) NOT NULL,
    typeGazon ENUM('Synthétique', 'Hybride') NOT NULL,
    tarifH    DECIMAL(7,3) NOT NULL,
    CONSTRAINT pk_terrain PRIMARY KEY (codeTer),
    CONSTRAINT chk_tarif  CHECK (tarifH > 0)
);

-- Q2 : Création de Reservation
CREATE TABLE Reservation (
    numRes   INT AUTO_INCREMENT,
    dateRes  DATE NOT NULL,
    heureDeb INT  NOT NULL,
    dureeH   INT  NOT NULL DEFAULT 1,
    codeTer  VARCHAR(5) NOT NULL,
    idEq     INT        NOT NULL,
    CONSTRAINT pk_reservation PRIMARY KEY (numRes),
    CONSTRAINT chk_duree      CHECK (dureeH BETWEEN 1 AND 3),
    CONSTRAINT fk_res_terrain FOREIGN KEY (codeTer)
        REFERENCES Terrain(codeTer)
        ON DELETE RESTRICT,
    CONSTRAINT fk_res_equipe  FOREIGN KEY (idEq)
        REFERENCES Equipe(idEq)
        ON DELETE CASCADE
);

-- Q3 : Évolutions ALTER TABLE
ALTER TABLE Equipe  ADD emailCap VARCHAR(80) NULL UNIQUE;
ALTER TABLE Terrain MODIFY nomTer VARCHAR(60) NOT NULL;
ALTER TABLE Equipe  CHANGE telCap telephone VARCHAR(20) NOT NULL;

-- ----------------------------------------------------------------------------
-- EXERCICE 4 : LMD — Insertions, mise à jour et suppression
-- ----------------------------------------------------------------------------

-- Q1 : Insertion multiple dans Terrain
INSERT INTO Terrain (codeTer, nomTer, typeGazon, tarifH) VALUES
('T01', 'Terrain Carthage', 'Synthétique', 60.000),
('T02', 'Terrain Hannibal', 'Hybride',     80.000);

-- Q2 : Insertion simple dans Equipe (idEq = 1)
INSERT INTO Equipe (nomEq, telephone, ville, emailCap)
VALUES ('Aigles Sousse', '22334455', 'Sousse', NULL);

-- Données de test dans Reservation (dont numRes = 15 pour tester Q4 et Q5)
INSERT INTO Reservation (numRes, dateRes, heureDeb, dureeH, codeTer, idEq) VALUES
(1,  '2026-11-25', 18, 2, 'T01', 1),
(2,  '2026-11-27', 20, 1, 'T02', 1),
(15, '2026-11-28', 19, 2, 'T01', 1);

-- Q3 : Augmentation de 10 DT pour les terrains Hybride (T02 passe à 90.000 DT)
UPDATE Terrain
SET tarifH = tarifH + 10
WHERE typeGazon = 'Hybride';

-- Q4 : Suppression de la réservation n°15
DELETE FROM Reservation
WHERE numRes = 15;

-- ----------------------------------------------------------------------------
-- EXERCICE 4 (Q5) : Tests d'intégrité (à décommenter dans l'onglet SQL)
-- ----------------------------------------------------------------------------

/*
-- Test 5a : ON DELETE CASCADE (supprime l'équipe 1 et ses réservations 1 et 2)
DELETE FROM Equipe WHERE idEq = 1;
SELECT * FROM Reservation; -- Renvoie 0 ligne

-- Test 5b : Violation d'intégrité référentielle (refusé : 'T99' inexistant)
INSERT INTO Reservation (dateRes, heureDeb, dureeH, codeTer, idEq)
VALUES ('2026-12-01', 19, 2, 'T99', 1);
*/