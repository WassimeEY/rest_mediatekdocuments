-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Généré le : ven. 28 fév. 2025 à 23:01
-- Version du serveur : 8.0.40-31
-- Version de PHP : 8.1.29

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
-- Structure de la table abonnement
--

CREATE TABLE abonnement (
  id varchar(5) NOT NULL,
  dateFinAbonnement date DEFAULT NULL,
  idRevue varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table abonnement
--

INSERT INTO abonnement (id, dateFinAbonnement, idRevue) VALUES
('00027', '2025-02-21', '10004'),
('28531', '2025-02-19', '10007'),
('33333', '2025-02-10', '10004'),
('3778', '2025-02-07', '10001'),
('42453', '2024-02-18', '10001'),
('55555', '2025-02-26', '10004'),
('64521', '2017-06-30', '10007'),
('64592', '2025-03-24', '10007'),
('66554', '2024-12-16', '10002'),
('7777', '2025-02-07', '10001');

-- --------------------------------------------------------

--
-- Structure de la table commande
--

CREATE TABLE commande (
  id varchar(5) NOT NULL,
  dateCommande date DEFAULT NULL,
  montant double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table commande
--

INSERT INTO commande (id, dateCommande, montant) VALUES
('00001', '2024-03-11', 46),
('00003', '2027-03-20', 645),
('00004', '2020-02-15', 251),
('00009', '2025-02-09', 25),
('00027', '2016-02-19', 354),
('10', '2025-02-11', 10),
('23232', '2024-09-04', 1),
('28', '2024-07-06', 333),
('28531', '2024-02-14', 656),
('33333', '2024-11-11', 22),
('3778', '2025-02-06', 66),
('42453', '2025-02-07', 12),
('55555', '2025-02-01', 2222),
('64521', '2015-01-07', 33),
('64592', '2024-10-18', 252),
('66554', '2024-12-15', 99),
('7777', '2021-02-01', 399);

--
-- Déclencheurs commande
--
DELIMITER $$
CREATE TRIGGER `DeleteAbonnementSiExiste` BEFORE DELETE ON `commande` FOR EACH ROW DELETE FROM abonnement AS abo
WHERE abo.id=old.id
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `DeleteCommandeDocSiExiste` BEFORE DELETE ON `commande` FOR EACH ROW DELETE FROM commandedocument AS cd
WHERE cd.id=old.id
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table commandedocument
--

CREATE TABLE commandedocument (
  id varchar(5) NOT NULL,
  nbExemplaire int DEFAULT NULL,
  idLivreDvd varchar(10) NOT NULL,
  idEtapeSuivi char(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table commandedocument
--

INSERT INTO commandedocument (id, nbExemplaire, idLivreDvd, idEtapeSuivi) VALUES
('00001', 124, '00004', '00001'),
('00003', 25, '00004', '00001'),
('00004', 12534, '00011', '00003'),
('00009', 88, '00005', '00001');

--
-- Déclencheurs commandedocument
--
DELIMITER $$
CREATE TRIGGER `AjoutExemplairesSiLivree` AFTER UPDATE ON `commandedocument` FOR EACH ROW
	BEGIN
	DECLARE compteur INTEGER;
	DECLARE prochainNumSequentielle INTEGER;
	DECLARE dateExemplaire DATE;
	SET compteur = new.nbExemplaire;
	SET prochainNumSequentielle = (SELECT MAX(ex.numero) FROM exemplaire AS ex WHERE ex.id = new.idLivreDvd ORDER BY ex.numero ASC);
    IF(prochainNumSequentielle IS NULL) THEN
    	SET prochainNumSequentielle = 1;
    END IF;
	SET dateExemplaire = (SELECT c.dateCommande FROM commandedocument AS cd JOIN commande AS c ON cd.id = c.id WHERE c.id = new.id);
	IF (new.idEtapeSuivi = '00003') THEN
		WHILE compteur > 0 DO
    		INSERT INTO exemplaire (id, numero, dateAchat, idEtat)
      		VALUES(new.idLivreDvd, prochainNumSequentielle, dateExemplaire, '00001');
        	SET compteur = compteur - 1;
        	SET prochainNumSequentielle = prochainNumSequentielle + 1 ;
         END WHILE;
     END IF;
END
$$
DELIMITER ;
-- --------------------------------------------------------

--
-- Structure de la table document
--

CREATE TABLE document (
  id varchar(10) NOT NULL,
  titre varchar(60) DEFAULT NULL,
  image varchar(500) DEFAULT NULL,
  idRayon varchar(5) NOT NULL,
  idPublic varchar(5) NOT NULL,
  idGenre varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table document
--

INSERT INTO document (id, titre, image, idRayon, idPublic, idGenre) VALUES
('00001', 'Quand sort la recluse', '', 'LV003', '00002', '10014'),
('00002', 'Un pays à l\'aube', '', 'LV001', '00002', '10004'),
('00003', 'Et je danse aussi', '', 'LV002', '00003', '10013'),
('00004', 'L\'armée furieuse', '', 'LV003', '00002', '10014'),
('00005', 'Les anonymes', '', 'LV001', '00002', '10014'),
('00006', 'La marque jaune', '', 'BD001', '00003', '10001'),
('00007', 'Dans les coulisses du musée', '', 'LV001', '00003', '10006'),
('00008', 'Histoire du juif errant', '', 'LV002', '00002', '10006'),
('00009', 'Pars vite et reviens tard', '', 'LV003', '00002', '10014'),
('00010', 'Le vestibule des causes perdues', '', 'LV001', '00002', '10006'),
('00011', 'L\'île des oubliés', '', 'LV002', '00003', '10006'),
('00012', 'La souris bleue', '', 'LV002', '00003', '10006'),
('00013', 'Sacré Pêre Noël', '', 'JN001', '00001', '10001'),
('00014', 'Mauvaise étoile', '', 'LV003', '00003', '10014'),
('00015', 'La confrérie des téméraires', '', 'JN002', '00004', '10014'),
('00016', 'Le butin du requin', '', 'JN002', '00004', '10014'),
('00017', 'Catastrophes au Brésil', '', 'JN002', '00004', '10014'),
('00018', 'Le Routard - Maroc', '', 'DV005', '00003', '10011'),
('00019', 'Guide Vert - Iles Canaries', '', 'DV005', '00003', '10011'),
('00020', 'Guide Vert - Irlande', '', 'DV005', '00003', '10011'),
('00021', 'Les déferlantes', '', 'LV002', '00002', '10006'),
('00022', 'Une part de Ciel', '', 'LV002', '00002', '10006'),
('00023', 'Le secret du janissaire', '', 'BD001', '00002', '10001'),
('00024', 'Pavillon noir', '', 'BD001', '00002', '10001'),
('00025', 'L\'archipel du danger', '', 'BD001', '00002', '10001'),
('00026', 'La planète des singes', '', 'LV002', '00003', '10002'),
('10001', 'Arts Magazine', '', 'PR002', '00002', '10016'),
('10002', 'Alternatives Economiques', '', 'PR002', '00002', '10015'),
('10003', 'Challenges', '', 'PR002', '00002', '10015'),
('10004', 'Rock and Folk', '', 'PR002', '00002', '10016'),
('10005', 'Les Echos', '', 'PR001', '00002', '10015'),
('10006', 'Le Monde', '', 'PR001', '00002', '10018'),
('10007', 'Telerama', '', 'PR002', '00002', '10016'),
('10008', 'L\'Obs', '', 'PR002', '00002', '10018'),
('10009', 'L\'Equipe', '', 'PR001', '00002', '10017'),
('10010', 'L\'Equipe Magazine', '', 'PR002', '00002', '10017'),
('10011', 'Geo', '', 'PR002', '00003', '10016'),
('20001', 'Star Wars 5 L\'empire contre attaque', '', 'DF001', '00003', '10002'),
('20002', 'Le seigneur des anneaux : la communauté de l\'anneau', '', 'DF001', '00003', '10019'),
('20003', 'Jurassic Park', '', 'DF001', '00003', '10002'),
('20004', 'Matrix', '', 'DF001', '00003', '10002');

-- --------------------------------------------------------

--
-- Structure de la table dvd
--

CREATE TABLE dvd (
  id varchar(10) NOT NULL,
  synopsis text,
  realisateur varchar(20) DEFAULT NULL,
  duree int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table dvd
--

INSERT INTO dvd (id, synopsis, realisateur, duree) VALUES
('20001', 'Luc est entraîné par Yoda pendant que Han et Leia tentent de se cacher dans la cité des nuages.', 'George Lucas', 124),
('20002', 'L\'anneau unique, forgé par Sauron, est porté par Fraudon qui l\'amène à Foncombe. De là, des représentants de peuples différents vont s\'unir pour aider Fraudon à amener l\'anneau à la montagne du Destin.', 'Peter Jackson', 228),
('20003', 'Un milliardaire et des généticiens créent des dinosaures à partir de clonage.', 'Steven Spielberg', 128),
('20004', 'Un informaticien réalise que le monde dans lequel il vit est une simulation gérée par des machines.', 'Les Wachowski', 136);

-- --------------------------------------------------------

--
-- Structure de la table etat
--

CREATE TABLE etat (
  id char(5) NOT NULL,
  libelle varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table etat
--

INSERT INTO etat (id, libelle) VALUES
('00001', 'neuf'),
('00002', 'usagé'),
('00003', 'détérioré'),
('00004', 'inutilisable');

-- --------------------------------------------------------

--
-- Structure de la table exemplaire
--

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
('00006', 1, '2024-05-14', '', '00001'),
('00006', 2, '2024-05-14', '', '00001'),
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

-- --------------------------------------------------------

--
-- Structure de la table genre
--

CREATE TABLE genre (
  id varchar(5) NOT NULL,
  libelle varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table genre
--

INSERT INTO genre (id, libelle) VALUES
('10000', 'Humour'),
('10001', 'Bande dessinée'),
('10002', 'Science Fiction'),
('10003', 'Biographie'),
('10004', 'Historique'),
('10006', 'Roman'),
('10007', 'Aventures'),
('10008', 'Essai'),
('10009', 'Documentaire'),
('10010', 'Technique'),
('10011', 'Voyages'),
('10012', 'Drame'),
('10013', 'Comédie'),
('10014', 'Policier'),
('10015', 'Presse Economique'),
('10016', 'Presse Culturelle'),
('10017', 'Presse sportive'),
('10018', 'Actualités'),
('10019', 'Fantazy');

-- --------------------------------------------------------

--
-- Structure de la table livre
--

CREATE TABLE livre (
  id varchar(10) NOT NULL,
  ISBN varchar(13) DEFAULT NULL,
  auteur varchar(20) DEFAULT NULL,
  collection varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table livre
--

INSERT INTO livre (id, ISBN, auteur, collection) VALUES
('00001', '1234569877896', 'Fred Vargas', 'Commissaire Adamsberg'),
('00002', '1236547896541', 'Dennis Lehanne', ''),
('00003', '6541236987410', 'Anne-Laure Bondoux', ''),
('00004', '3214569874123', 'Fred Vargas', 'Commissaire Adamsberg'),
('00005', '3214563214563', 'RJ Ellory', ''),
('00006', '3213213211232', 'Edgar P. Jacobs', 'Blake et Mortimer'),
('00007', '6541236987541', 'Kate Atkinson', ''),
('00008', '1236987456321', 'Jean d\'Ormesson', ''),
('00009', '', 'Fred Vargas', 'Commissaire Adamsberg'),
('00010', '', 'Manon Moreau', ''),
('00011', '', 'Victoria Hislop', ''),
('00012', '', 'Kate Atkinson', ''),
('00013', '', 'Raymond Briggs', ''),
('00014', '', 'RJ Ellory', ''),
('00015', '', 'Floriane Turmeau', ''),
('00016', '', 'Julian Press', ''),
('00017', '', 'Philippe Masson', ''),
('00018', '', '', 'Guide du Routard'),
('00019', '', '', 'Guide Vert'),
('00020', '', '', 'Guide Vert'),
('00021', '', 'Claudie Gallay', ''),
('00022', '', 'Claudie Gallay', ''),
('00023', '', 'Ayrolles - Masbou', 'De cape et de crocs'),
('00024', '', 'Ayrolles - Masbou', 'De cape et de crocs'),
('00025', '', 'Ayrolles - Masbou', 'De cape et de crocs'),
('00026', '', 'Pierre Boulle', 'Julliard');

-- --------------------------------------------------------

--
-- Structure de la table livres_dvd
--

CREATE TABLE livres_dvd (
  id varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table livres_dvd
--

INSERT INTO livres_dvd (id) VALUES
('00001'),
('00002'),
('00003'),
('00004'),
('00005'),
('00006'),
('00007'),
('00008'),
('00009'),
('00010'),
('00011'),
('00012'),
('00013'),
('00014'),
('00015'),
('00016'),
('00017'),
('00018'),
('00019'),
('00020'),
('00021'),
('00022'),
('00023'),
('00024'),
('00025'),
('00026'),
('20001'),
('20002'),
('20003'),
('20004');

-- --------------------------------------------------------

--
-- Structure de la table public
--

CREATE TABLE public (
  id varchar(5) NOT NULL,
  libelle varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table public
--

INSERT INTO public (id, libelle) VALUES
('00001', 'Jeunesse'),
('00002', 'Adultes'),
('00003', 'Tous publics'),
('00004', 'Ados');

-- --------------------------------------------------------

--
-- Structure de la table rayon
--

CREATE TABLE rayon (
  id char(5) NOT NULL,
  libelle varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table rayon
--

INSERT INTO rayon (id, libelle) VALUES
('BD001', 'BD Adultes'),
('BL001', 'Beaux Livres'),
('DF001', 'DVD films'),
('DV001', 'Sciences'),
('DV002', 'Maison'),
('DV003', 'Santé'),
('DV004', 'Littérature classique'),
('DV005', 'Voyages'),
('JN001', 'Jeunesse BD'),
('JN002', 'Jeunesse romans'),
('LV001', 'Littérature étrangère'),
('LV002', 'Littérature française'),
('LV003', 'Policiers français étrangers'),
('PR001', 'Presse quotidienne'),
('PR002', 'Magazines');

-- --------------------------------------------------------

--
-- Structure de la table revue
--

CREATE TABLE revue (
  id varchar(10) NOT NULL,
  periodicite varchar(2) DEFAULT NULL,
  delaiMiseADispo int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table revue
--

INSERT INTO revue (id, periodicite, delaiMiseADispo) VALUES
('10001', 'MS', 52),
('10002', 'MS', 52),
('10003', 'HB', 15),
('10004', 'HB', 15),
('10005', 'QT', 5),
('10006', 'QT', 5),
('10007', 'HB', 26),
('10008', 'HB', 26),
('10009', 'QT', 5),
('10010', 'HB', 12),
('10011', 'MS', 52);

-- --------------------------------------------------------

--
-- Structure de la table service
--

CREATE TABLE service (
  id varchar(10) NOT NULL,
  libelle varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table service
--

INSERT INTO service (id, libelle) VALUES
('00001', 'Culture'),
('00002', 'Prêts'),
('00003', 'Administratif');

-- --------------------------------------------------------

--
-- Structure de la table suivi
--

CREATE TABLE suivi (
  id char(5) NOT NULL,
  libelle varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table suivi
--

INSERT INTO suivi (id, libelle) VALUES
('00001', 'en cours'),
('00002', 'relancée'),
('00003', 'livrée'),
('00004', 'réglée');

-- --------------------------------------------------------

--
-- Structure de la table utilisateur
--

CREATE TABLE utilisateur (
  id varchar(10) NOT NULL,
  login varchar(50) NOT NULL,
  mdp varchar(255) NOT NULL,
  idService varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table utilisateur
--

INSERT INTO utilisateur (id, login, mdp, idService) VALUES
('00001', 'JhonDoe', '$2y$10$QM.lb2wJCbRVedS60kbw9eGIzARdlhXaCURZ/P3XzrCx7KmDSmAru', '00001'),
('00002', 'PatrickLauron', '$2y$10$PNgnXqzG2EiPcTWaF.xIHOMSy1A/JLIa/eUbLZuCS/m4e0x3L/zzK', '00002'),
('00003', 'AmbessaBegin', '$2y$10$IKBY57ZYhFfcXQtMk6fRU.k6isq3V5C8GPyh6LQQ81bWfMCHrCf4K', '00003');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table abonnement
--
ALTER TABLE abonnement
  ADD PRIMARY KEY (id),
  ADD KEY idRevue (idRevue);

--
-- Index pour la table commande
--
ALTER TABLE commande
  ADD PRIMARY KEY (id);

--
-- Index pour la table commandedocument
--
ALTER TABLE commandedocument
  ADD PRIMARY KEY (id),
  ADD KEY idLivreDvd (idLivreDvd),
  ADD KEY commandedocument_ibfk_3 (idEtapeSuivi);

--
-- Index pour la table document
--
ALTER TABLE document
  ADD PRIMARY KEY (id),
  ADD KEY idRayon (idRayon),
  ADD KEY idPublic (idPublic),
  ADD KEY idGenre (idGenre);

--
-- Index pour la table dvd
--
ALTER TABLE dvd
  ADD PRIMARY KEY (id);

--
-- Index pour la table etat
--
ALTER TABLE etat
  ADD PRIMARY KEY (id);

--
-- Index pour la table exemplaire
--
ALTER TABLE exemplaire
  ADD PRIMARY KEY (id,numero),
  ADD KEY idEtat (idEtat);

--
-- Index pour la table genre
--
ALTER TABLE genre
  ADD PRIMARY KEY (id);

--
-- Index pour la table livre
--
ALTER TABLE livre
  ADD PRIMARY KEY (id);

--
-- Index pour la table livres_dvd
--
ALTER TABLE livres_dvd
  ADD PRIMARY KEY (id);

--
-- Index pour la table public
--
ALTER TABLE public
  ADD PRIMARY KEY (id);

--
-- Index pour la table rayon
--
ALTER TABLE rayon
  ADD PRIMARY KEY (id);

--
-- Index pour la table revue
--
ALTER TABLE revue
  ADD PRIMARY KEY (id);

--
-- Index pour la table service
--
ALTER TABLE service
  ADD PRIMARY KEY (id);

--
-- Index pour la table suivi
--
ALTER TABLE suivi
  ADD PRIMARY KEY (id);

--
-- Index pour la table utilisateur
--
ALTER TABLE utilisateur
  ADD PRIMARY KEY (id),
  ADD KEY utilisateur_ibfk_1 (idService);

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table abonnement
--
ALTER TABLE abonnement
  ADD CONSTRAINT abonnement_ibfk_1 FOREIGN KEY (id) REFERENCES commande (id),
  ADD CONSTRAINT abonnement_ibfk_2 FOREIGN KEY (idRevue) REFERENCES revue (id);

--
-- Contraintes pour la table commandedocument
--
ALTER TABLE commandedocument
  ADD CONSTRAINT commandedocument_ibfk_1 FOREIGN KEY (id) REFERENCES commande (id),
  ADD CONSTRAINT commandedocument_ibfk_2 FOREIGN KEY (idLivreDvd) REFERENCES livres_dvd (id),
  ADD CONSTRAINT commandedocument_ibfk_3 FOREIGN KEY (idEtapeSuivi) REFERENCES suivi (id) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table document
--
ALTER TABLE document
  ADD CONSTRAINT document_ibfk_1 FOREIGN KEY (idRayon) REFERENCES rayon (id),
  ADD CONSTRAINT document_ibfk_2 FOREIGN KEY (idPublic) REFERENCES public (id),
  ADD CONSTRAINT document_ibfk_3 FOREIGN KEY (idGenre) REFERENCES genre (id);

--
-- Contraintes pour la table dvd
--
ALTER TABLE dvd
  ADD CONSTRAINT dvd_ibfk_1 FOREIGN KEY (id) REFERENCES livres_dvd (id);

--
-- Contraintes pour la table exemplaire
--
ALTER TABLE exemplaire
  ADD CONSTRAINT exemplaire_ibfk_1 FOREIGN KEY (id) REFERENCES document (id),
  ADD CONSTRAINT exemplaire_ibfk_2 FOREIGN KEY (idEtat) REFERENCES etat (id);

--
-- Contraintes pour la table livre
--
ALTER TABLE livre
  ADD CONSTRAINT livre_ibfk_1 FOREIGN KEY (id) REFERENCES livres_dvd (id);

--
-- Contraintes pour la table livres_dvd
--
ALTER TABLE livres_dvd
  ADD CONSTRAINT livres_dvd_ibfk_1 FOREIGN KEY (id) REFERENCES document (id);

--
-- Contraintes pour la table revue
--
ALTER TABLE revue
  ADD CONSTRAINT revue_ibfk_1 FOREIGN KEY (id) REFERENCES document (id);

--
-- Contraintes pour la table utilisateur
--
ALTER TABLE utilisateur
  ADD CONSTRAINT utilisateur_ibfk_1 FOREIGN KEY (idService) REFERENCES service (id) ON DELETE RESTRICT ON UPDATE RESTRICT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
