# **R5.A.13 - Économie durable et numérique**

## **Projet de Smart-contract : Voting**

Objectif : Mettre en place un smart contract permettant des sessions de vote.  



## **Fonctionnalités additionnelles**
Fonctionnalités additionnelles (il s'agit surtout d'ajouts permettant au/à la contractOwner de pouvoir avoir plus de contrôle sur le contract qu'il/elle/iel déploie) :  

    - Un.e Voter ne peut voter que pour une et une seule proposition
    - Possibilité d'ajouter un.e Voter 1 par 1  
    - Possibilité de reset une session dans sa globalité (cas ex: suspicion de triche, session non réglementaire, ...)  
    - Possibilité de reset à la phase de soumission des propositions (cas ex: suspicion de triche)  
    - Possibilité de remove un.e Voter de la liste des Voters
    - Possibilité de remove plusieurs Voters de la liste des Voters


## **Test du backend**

**UTILISATION DE L'IDE [REMIX](https://remix.ethereum.org/) RECOMMANDÉE POUR TESTER LE BACKEND** 
 
- Se rendre sur l'IDE sur navigateur [REMIX](https://remix.ethereum.org/)  
- Cloner le repo Git :  
  - Cliquer sur `WORKSPACE`  
  - Cliquer sur `Clone`  
  - Entrer le lien de clonage de ce projet : https://github.com/AdrienDCV/smart-contract.git  
- Compiler le fichier `Voting.sol`  
  - Ouvrir le fichier `Voting.sol` trouvable dans `/truffle/contracts/Voting.sol`  
  - `Ctrl + S` ou cliquer sur `Solidity compiler` dans la barre de menu sur la gauche puis sur `Compile Voting.sol`  
- Déployer le contract :
  - Cliquer sur l'icône `Deploy & run transaction` dans la barre de menu sur la gauche (juste en dessous du compilateur vu pécédement)
  - Sélectionner un compte parmi les comptes de tests
  - Copier/coller l'adresse du compte à côté du bouton orange nommé `Deploy`
  - Cliquer sur `Deploy`

Vous pouvez maintenant tester les différentes fonctionnalités du smart-contract `Voting`.  


## **Informations**  

Une grande partie des fonctions renvoient une string en sortie.  
Cela est volontaire étant donné que mon projet ne possède pas de front. J'ai choisi de procéder ainsi afin de pouvoir profiter d'un suivi dans les différentes actions réalisées lors d'une utilisation du contract. 
Les différents messages de suivi sont visibles dans les output de chaque transaction. 

---
DA COSTA VEIGA  
Adrien  
Alternant en 3ème année de BUT Informatique, parcours réalisation d'applications  