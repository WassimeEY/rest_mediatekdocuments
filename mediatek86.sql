-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : ven. 28 fév. 2025 à 21:00
-- Version du serveur : 8.3.0
-- Version de PHP : 8.2.18

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : mediatek86
--

-- --------------------------------------------------------

--
-- Structure de la table exemplaire
--

DROP TABLE IF EXISTS exemplaire;
CREATE TABLE exemplaire (
  id varchar(10) NOT NULL,
  numero int NOT NULL,
  dateAchat date DEFAULT NULL,
  photo varchar(500) NOT NULL,
  idEtat char(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table exemplaire
--

INSERT INTO exemplaire (id, numero, dateAchat, photo, idEtat) VALUES
('10001', 21, '2025-02-05', '', '00001'),
('10001', 25, '2025-02-03', '', '00001'),
('10001', 263, '2025-02-05', '', '00001'),
('10001', 1502, '2023-05-19', '', '00001'),
('10001', 1505, '2023-05-14', '', '00001'),
('10001', 1577, '2038-05-14', '', '00001'),
('10001', 10002, '2025-02-03', '', '00001'),
('10002', 418, '2021-12-01', '', '00001'),
('10007', 3237, '2021-11-23', '', '00001'),
('10007', 3238, '2021-11-30', '', '00001'),
('10007', 3239, '2021-12-07', '', '00001'),
('10007', 3240, '2021-12-21', '', '00001'),
('10011', 505, '2022-10-16', '', '00001'),
('10011', 506, '2021-04-01', '', '00001'),
('10011', 507, '2021-05-03', '', '00001'),
('10011', 508, '2021-06-05', '', '00001'),
('10011', 509, '2021-07-01', '', '00001'),
('10011', 510, '2021-08-04', '', '00001'),
('10011', 511, '2021-09-01', '', '00001'),
('10011', 512, '2021-10-06', '', '00001'),
('10011', 513, '2021-11-01', '', '00001'),
('10011', 514, '2021-12-01', '', '00001');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table exemplaire
--
ALTER TABLE exemplaire
  ADD PRIMARY KEY (id,numero),
  ADD KEY idEtat (idEtat);

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table exemplaire
--
ALTER TABLE exemplaire
  ADD CONSTRAINT exemplaire_ibfk_1 FOREIGN KEY (id) REFERENCES document (id),
  ADD CONSTRAINT exemplaire_ibfk_2 FOREIGN KEY (idEtat) REFERENCES etat (id);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
