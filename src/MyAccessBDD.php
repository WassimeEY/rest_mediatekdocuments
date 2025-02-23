<?php
include_once("AccessBDD.php");

/**
 * Classe de construction des requêtes SQL
 * hérite de AccessBDD qui contient les requêtes de base
 * Pour ajouter une requête :
 * - créer la fonction qui crée une requête (prendre modèle sur les fonctions 
 *   existantes qui ne commencent pas par 'traitement')
 * - ajouter un 'case' dans un des switch des fonctions redéfinies 
 * - appeler la nouvelle fonction dans ce 'case'
 */
class MyAccessBDD extends AccessBDD {
	    
    /**
     * constructeur qui appelle celui de la classe mère
     */
    public function __construct(){
        try{
            parent::__construct();
        }catch(Exception $e){
            throw $e;
        }
    }

    /**
     * demande de recherche
     * @param string $table
     * @param array|null $champs nom et valeur de chaque champ
     * @return array|null tuples du résultat de la requête ou null si erreur
     * @override
     */	
    protected function traitementSelect(string $table, ?array $champs) : ?array{
        switch($table){  
            case "livre" :
                return $this->selectAllLivres();
            case "dvd" :
                return $this->selectAllDvd();
            case "revue" :
                return $this->selectAllRevues();
            case "exemplaire" :
                return $this->selectExemplairesRevue($champs);
            case "genre" :
            case "public" :
            case "rayon" :
            case "etat" :
                // select portant sur une table contenant juste id et libelle
                return $this->selectTableSimple($table);
            case "commandedocument" :
                if (empty($champs)) {
                    return $this->selectAllCommandesDoc();
                }
                return $this->selectCommandesDoc($champs);
            case "abonnement" :
                if (empty($champs)) {
                    return $this->selectAllAbonnements();
                }
                else if (array_key_exists('periodeRestanteMin', $champs)) {
                    return $this->selectAbonnementsRevueBientotExpire($champs);
                }
                return $this->selectAbonnementsRevue($champs);
            case "utilisateur":
                if($this->selecUtilisateurValide($champs)){
                    return $this->selecUtilisateurValide($champs);
                }
                else{
                    return null;
                }
            default:
                // cas général
                return $this->selectTuplesOneTable($table, $champs);
        }	
    }

    /**
     * demande d'ajout (insert)
     * @param string $table
     * @param array|null $champs nom et valeur de chaque champ
     * @return int|null nombre de tuples ajoutés ou null si erreur
     * @override
     */	
    protected function traitementInsert(string $table, ?array $champs) : ?int{
        switch($table){
            case "commandedocument" :
                return $this->insertOneCommandeDocument($champs);
            case "abonnement" :
                return $this->insertOneAbonnement($champs);
            default:                    
                // cas général
                return $this->insertOneTupleOneTable($table, $champs);	
        }
    }
    
    /**
     * demande de modification (update)
     * @param string $table
     * @param string|null $id
     * @param array|null $champs nom et valeur de chaque champ
     * @return int|null nombre de tuples modifiés ou null si erreur
     * @override
     */	
    protected function traitementUpdate(string $table, ?string $id, ?array $champs) : ?int{
        switch($table){
            case "commandedocument" :
                // return $this->uneFonction(parametres);
            default:                    
                // cas général
                return $this->updateOneTupleOneTable($table, $id, $champs);
        }	
    }  
    
    /**
     * demande de suppression (delete)
     * @param string $table
     * @param array|null $champs nom et valeur de chaque champ
     * @return int|null nombre de tuples supprimés ou null si erreur
     * @override
     */	
    protected function traitementDelete(string $table, ?array $champs) : ?int{
        switch($table){
            case "" :
                // return $this->uneFonction(parametres);
            default:                    
                // cas général
                //var_dump($champs);
                return $this->deleteTuplesOneTable($table, $champs);	
        }
    }	    
        
    /**
     * récupère les tuples d'une seule table
     * @param string $table
     * @param array|null $champs
     * @return array|null 
     */
    private function selectTuplesOneTable(string $table, ?array $champs) : ?array{
        if(empty($champs)){
            // tous les tuples d'une table
            $requete = "select * from $table;";
            return $this->conn->queryBDD($requete);  
        }else{
            // tuples spécifiques d'une table
            $requete = "select * from $table where ";
            foreach ($champs as $key => $value){
                $requete .= "$key=:$key and ";
            }
            // (enlève le dernier and)
            $requete = substr($requete, 0, strlen($requete)-5);	          
            return $this->conn->queryBDD($requete, $champs);
        }
    }	

     /**
     * demande d'ajout (insert) d'une commandeDocument, on va l'ajouter dans la table commande également car commandedocument hérite de cette table.
     * @param array|null $champs
     * @return int|null nombre de commandeDocument ajoutées (0 ou 1) ou null si erreur
     */	
    private function insertOneCommandeDocument(?array $champs) : ?int{
        if(empty($champs)){
            return null;
        }
        $champsCommande = $champs;
        unset($champsCommande['IdLivreDvd']);
        unset($champsCommande['IdEtapeSuivi']);
        unset($champsCommande['NbExemplaire']);
        unset($champsCommande['EtapeSuiviLibelle']);
        $champsCommandeDoc = $champs;
        unset($champsCommandeDoc['EtapeSuiviLibelle']);
        unset($champsCommandeDoc['DateCommande']);
        unset($champsCommandeDoc['Montant']);
        $retourInsertCommande = $this->insertOneTupleOneTable("commande",$champsCommande);
        $retourInsertCommandeDoc = $this->insertOneTupleOneTable("commandedocument",$champsCommandeDoc);
        if($retourInsertCommande == null || $retourInsertCommandeDoc == null){
            return null;
        }
        else{
            if(($retourInsertCommande+$retourInsertCommandeDoc) == 2){
                return 1; //on aura donc bien ajouté une commande de document.
            }
            else{
                return 0;
            }
        }
    }
    
    /**
     * demande d'ajout (insert) d'un abonnement, on va l'ajouter dans la table commande également car abonnement hérite de cette table.
     * @param array|null $champs
     * @return int|null nombre de abonnement ajoutées (0 ou 1) ou null si erreur
     */	
    private function insertOneAbonnement(?array $champs) : ?int{
        if(empty($champs)){
            return null;
        }
        $champsCommande = $champs;
        unset($champsCommande['DateFinAbonnement']);
        unset($champsCommande['IdRevue']);
        unset($champsCommande['TitreRevue']);
        $champsAbonnement = $champs;
        unset($champsAbonnement['DateCommande']);
        unset($champsAbonnement['Montant']);
        unset($champsAbonnement['TitreRevue']);
        $retourInsertCommande = $this->insertOneTupleOneTable("commande",$champsCommande);
        $retourInsertAbonnement = $this->insertOneTupleOneTable("abonnement",$champsAbonnement);
        if($retourInsertCommande == null || $retourInsertAbonnement == null){
            return null;
        }
        else{
            if(($retourInsertCommande+$retourInsertAbonnement) == 2){
                return 1; //on aura donc bien ajouté un abonnement.
            }
            else{
                return 0;
            }
        }
    }
    
    /**
     * demande d'ajout (insert) d'un tuple dans une table
     * @param string $table
     * @param array|null $champs
     * @return int|null nombre de tuples ajoutés (0 ou 1) ou null si erreur
     */	
    private function insertOneTupleOneTable(string $table, ?array $champs) : ?int{
        if(empty($champs)){
            return null;
        }
        //var_dump($champs);
        // construction de la requête
        $requete = "insert into $table (";
        foreach ($champs as $key => $value){
            $requete .= "$key,";
        }
        // (enlève la dernière virgule)
        $requete = substr($requete, 0, strlen($requete)-1);
        $requete .= ") values (";
        foreach ($champs as $key => $value){
            $requete .= ":$key,";
        }
        // (enlève la dernière virgule)
        $requete = substr($requete, 0, strlen($requete)-1);
        $requete .= ");";
        return $this->conn->updateBDD($requete, $champs);
    }

    /**
     * demande de modification (update) d'un tuple dans une table
     * @param string $table
     * @param string\null $id
     * @param array|null $champs 
     * @return int|null nombre de tuples modifiés (0 ou 1) ou null si erreur
     */	
    private function updateOneTupleOneTable(string $table, ?string $id, ?array $champs) : ?int {
        if(empty($champs)){
            return null;
        }
        if(is_null($id)){
            return null;
        }
        // construction de la requête
        $requete = "update $table set ";
        foreach ($champs as $key => $value){
            $requete .= "$key=:$key,";
        }
        // (enlève la dernière virgule)
        $requete = substr($requete, 0, strlen($requete)-1);				
        $champs["id"] = $id;
        $requete .= " where id=:id;";		
        return $this->conn->updateBDD($requete, $champs);	        
    }
    
    /**
     * demande de suppression (delete) d'un ou plusieurs tuples dans une table
     * @param string $table
     * @param array|null $champs
     * @return int|null nombre de tuples supprimés ou null si erreur
     */
    private function deleteTuplesOneTable(string $table, ?array $champs) : ?int{
        if(empty($champs)){
            return null;
        }
        // construction de la requête
        $requete = "delete from $table where ";
        foreach ($champs as $key => $value){
            //echo "\n-".$key."\n-";
            $requete .= "$key=:$key and ";
        }
        // (enlève le dernier and)
        $requete = substr($requete, 0, strlen($requete)-5);   
        //echo "\n".$requete;
        return $this->conn->updateBDD($requete, $champs);	        
    }
 
    /**
     * récupère toutes les lignes d'une table simple (qui contient juste id et libelle)
     * @param string $table
     * @return array|null
     */
    private function selectTableSimple(string $table) : ?array{
        $requete = "select * from $table order by libelle;";		
        return $this->conn->queryBDD($requete);	    
    }
    
    /**
     * récupère toutes les lignes de la table Livre et les tables associées
     * @return array|null
     */
    private function selectAllLivres() : ?array{
        $requete = "Select l.id, l.ISBN, l.auteur, d.titre, d.image, l.collection, ";
        $requete .= "d.idrayon, d.idpublic, d.idgenre, g.libelle as genre, p.libelle as lePublic, r.libelle as rayon ";
        $requete .= "from livre l join document d on l.id=d.id ";
        $requete .= "join genre g on g.id=d.idGenre ";
        $requete .= "join public p on p.id=d.idPublic ";
        $requete .= "join rayon r on r.id=d.idRayon ";
        $requete .= "order by titre ";		
        return $this->conn->queryBDD($requete);
    }	

    /**
     * récupère toutes les lignes de la table DVD et les tables associées
     * @return array|null
     */
    private function selectAllDvd() : ?array{
        $requete = "Select l.id, l.duree, l.realisateur, d.titre, d.image, l.synopsis, ";
        $requete .= "d.idrayon, d.idpublic, d.idgenre, g.libelle as genre, p.libelle as lePublic, r.libelle as rayon ";
        $requete .= "from dvd l join document d on l.id=d.id ";
        $requete .= "join genre g on g.id=d.idGenre ";
        $requete .= "join public p on p.id=d.idPublic ";
        $requete .= "join rayon r on r.id=d.idRayon ";
        $requete .= "order by titre ";	
        return $this->conn->queryBDD($requete);
    }	

    /**
     * récupère toutes les lignes de la table Revue et les tables associées
     * @return array|null
     */
    private function selectAllRevues() : ?array{
        $requete = "Select l.id, l.periodicite, d.titre, d.image, l.delaiMiseADispo, ";
        $requete .= "d.idrayon, d.idpublic, d.idgenre, g.libelle as genre, p.libelle as lePublic, r.libelle as rayon ";
        $requete .= "from revue l join document d on l.id=d.id ";
        $requete .= "join genre g on g.id=d.idGenre ";
        $requete .= "join public p on p.id=d.idPublic ";
        $requete .= "join rayon r on r.id=d.idRayon ";
        $requete .= "order by titre ";
        return $this->conn->queryBDD($requete);
    }	

     /**
     * récupère toutes les lignes de la table commandedocument et les tables associées
     * @return array|null
     */
    private function selectAllCommandesDoc() : ?array{
        $requete = "Select c.id, c.dateCommande, c.montant, cd.nbExemplaire, cd.idLivreDvd, sui.id as idEtapeSuivi, sui.libelle as etapeSuiviLibelle ";
        $requete .= "from commandedocument AS cd ";
        $requete .= "join commande AS c on cd.id=c.id ";
        $requete .= "left join suivi AS sui ON cd.idEtapeSuivi = sui.id ";
        $requete .= "order by c.dateCommande DESC ";
        return $this->conn->queryBDD($requete);
    }	
    
    /**
     * récupère toutes les lignes de la table abonnement et les tables associées
     * @return array|null
     */
    private function selectAllAbonnements() : ?array{
        $requete = "Select abo.id, c.dateCommande, c.montant, abo.dateFinAbonnement, abo.idRevue ";
        $requete .= "from abonnement AS abo ";
        $requete .= "join commande AS c on abo.id=c.id ";
        $requete .= "order by c.dateCommande DESC ";
        return $this->conn->queryBDD($requete);
    }	
    
    /**
     * récupère tous les exemplaires d'une revue
     * @param array|null $champs 
     * @return array|null
     */
    private function selectExemplairesRevue(?array $champs) : ?array{
        if(empty($champs)){
            return null;
        }
        if(!array_key_exists('id', $champs)){
            return null;
        }
        $champNecessaire['id'] = $champs['id'];
        $requete = "Select e.id, e.numero, e.dateAchat, e.photo, e.idEtat ";
        $requete .= "from exemplaire e join document d on e.id=d.id ";
        $requete .= "where e.id = :id ";
        $requete .= "order by e.dateAchat DESC";
        return $this->conn->queryBDD($requete, $champNecessaire);
    }

    /**
     * récupère toutes les lignes de la table commandedocument et des tables associées, basé à partir de l'id du doc fournit dans la variable $champs.
     * @param array|null $champs
     * @return array|null
     */
    private function selectCommandesDoc(?array $champs): ?array {
        $champNecessaire['idLivreDvd'] = $champs['idLivreDvd'];
        $requete = "Select c.id, c.dateCommande, c.montant, cd.nbExemplaire, cd.idLivreDvd, sui.id as idEtapeSuivi, sui.libelle as etapeSuiviLibelle ";
        $requete .= "from commandedocument AS cd ";
        $requete .= "join commande AS c on cd.id=c.id ";
        $requete .= "left join suivi AS sui ON cd.idEtapeSuivi = sui.id ";
        $requete .= "where cd.idLivreDvd = :idLivreDvd ";
        $requete .= "order by c.dateCommande DESC ";
        return $this->conn->queryBDD($requete, $champNecessaire);
    }
    
     /**
     * récupère toutes les lignes de la table abonnement et des tables associées, basé à partir de l'id du doc fournit (la revue) dans la variable $champs.
     * @return array|null
     */
    private function selectAbonnementsRevue(?array $champs) : ?array{
        //echo"hg";
        $champNecessaire['idRevue'] = $champs['idRevue'];
        $requete = "Select abo.id, c.dateCommande, c.montant, abo.dateFinAbonnement, abo.idRevue, doc.titre AS titreRevue ";
        $requete .= "from abonnement AS abo ";
        $requete .= "join commande AS c on abo.id=c.id ";
        $requete .= "left join document AS doc on abo.idRevue=doc.id ";
        $requete .= "where abo.idRevue = :idRevue ";
        $requete .= "order by c.dateCommande DESC ";
        return $this->conn->queryBDD($requete, $champNecessaire);
    }
    
    /**
     * Récupère toutes les lignes de la table abonnement et des tables associées, basé à partir de l'id du doc fournit (la revue) dans la variable $champs.
     * On a également le champ periodeRestanteMin 
     * @return array|null
     */
    private function selectAbonnementsRevueBientotExpire(?array $champs) : ?array{
        $champNecessaire['periodeRestanteMin'] = $champs['periodeRestanteMin'];
        $requete = "Select abo.id, c.dateCommande, c.montant, abo.dateFinAbonnement, abo.idRevue, doc.titre AS titreRevue ";
        $requete .= "from abonnement AS abo ";
        $requete .= "join commande AS c on abo.id=c.id ";
        $requete .= "left join document AS doc on abo.idRevue=doc.id ";
        $requete .= "where DATEDIFF(NOW(), abo.dateFinAbonnement) >= -:periodeRestanteMin and DATEDIFF(NOW(), abo.dateFinAbonnement) <= 0 ";
        $requete .= "order by abo.dateFinAbonnement ASC ";
        //var_dump($requete);
        return $this->conn->queryBDD($requete, $champNecessaire);
    }
    
    /**
     * Récupère la ligne de la table utilisateur et des tables associées, basé à partir du login et du mdp non haché fournit dans la variable $champs.
     * On va haché le mdp avant de faire le comparaision.
     * On va également séparer deux requêtes SQL pour éviter de retourner le mdp haché (car la vérification est déjà faite avec le password_verify().
     * @param array|null $champs
     * @return array|null
     */
    private function selecUtilisateurValide(?array $champs): ?array {
        $mdpNonHache = $champs['mdp'];
        $champNecessaire['login'] = $champs['login'];
        $requeteMdp = "Select uti.mdp ";
        $requeteMdp .= "from utilisateur AS uti ";
        $requeteMdp .= "where uti.login = :login ";
        $result = $this->conn->queryBDD($requeteMdp, $champNecessaire);
        if($result == null){
            //var_dump($champs['login']);
            //var_dump($champs['mdp']);
            //var_dump($requeteMdp);
            //var_dump($champNecessaire);
            return null;
        }
        $mdpHache = $result[0]['mdp'];
        //echo"g";
        //$requete = "Select uti.idService ";
        //$requete .= "from utilisateur AS uti ";
        //$requete .= "where uti.login = :login ";
        if (password_verify($mdpNonHache, $mdpHache)) {
            $requeteService = "Select uti.idService, ser.libelle AS LibelleService ";
            $requeteService .= "from utilisateur AS uti ";
            $requeteService .= "join service AS ser ON uti.idService = ser.id ";
            $requeteService .= "where uti.login = :login ";
            return $this->conn->queryBDD($requeteService, $champNecessaire);
        } else {
            return null;
        }
    }

    /**
     * demande de modification (update) d'une commande de document
     * @param string\null $id
     * @param array|null $champs 
     * @return int|null nombre de tuples modifiés (0 ou 1) ou null si erreur
     */	
    private function updateCommandeDocument(?string $id, ?array $champs) : ?int {
        if(empty($champs)){
            return null;
        }
        if(is_null($id)){
            return null;
        }
        $champsTableFilleCommandeDoc = $champs;
        unset($champsTableFilleCommandeDoc['DateCommande']);
        unset($champsTableFilleCommandeDoc['Montant']);
        // construction de la requête
        $requete = "update commandedocument set ";
        foreach ($champs as $key => $value){
            $requete .= "$key=:$key,";
        }
        // (enlève la dernière virgule)
        $requete = substr($requete, 0, strlen($requete)-1);				
        $champs["id"] = $id;
        $requete .= " where id=:id;";		
        return $this->conn->updateBDD($requete, $champs);	        
    }
    
}
