/**
 * Created by LanaPC on 10.07.2016.
 */

public with sharing class AccountShareHandler {
   public List<TerrUser__c> terrUsersMain;
    public List<AccountShare> accShareList;

    public AccountShareHandler(){
        terrUsersMain=new List<TerrUser__c>();
        accShareList=new List<AccountShare>();
    }
    public void handlleAccountShare(Id accId) {
        //inserted accoutnt, or apdated
        Account acc = [SELECT id, name, Territory__r.Id FROM Account WHERE id = :accId];
        System.debug(acc.Territory__r.id);

        //ter of current account
        Territory__c terr = [SELECT id, name, ParenTerritory__r.Id FROM Territory__c WHERE id = :acc.Territory__r.Id];

        List<TerrUser__c> terrUsers = [SELECT id, name, user__r.id FROM TerrUser__c WHERE Territory__r.id = :acc.Territory__r.Id];
        if (terrUsers.size() != 0) {
            for (TerrUser__c t: terrUsers) {
                System.debug(t.name);
            }
        terrUsersMain.addAll(terrUsers);
        }

          getParent(terr);

            System.debug(terrUsersMain.size());
        if (terrUsersMain.size() != 0) {
            for (TerrUser__c t: terrUsersMain) {
                System.debug(t.name);
            }
        }

        if (terrUsersMain.size() != 0) {
            for (TerrUser__c t: terrUsersMain) {
                AccountShare accShare =new AccountShare();
                accShare.AccountId=acc.Id;
                accShare.UserOrGroupId = t.user__r.id;
                accShare.OpportunityAccessLevel='none';
                accShare.AccountAccessLevel = 'Read';
                accShareList.add(accShare);


            }
            upsert accShareList;
        }



    }
    public void getParent(Territory__c terr){
        List<TerrUser__c> terrUsers = new List<TerrUser__c>();
        if(terr.ParenTerritory__r.id!=null){
            Territory__c parentTerritory = [SELECT id,name, ParenTerritory__r.Id FROM Territory__c WHERE id=:terr.ParenTerritory__r.id];
            terrUsers = [SELECT id,name,user__r.id FROM TerrUser__c WHERE Territory__r.id=:parentTerritory.id];
            if(terrUsers.size()!=0){
                /*for(TerrUser__c t: terrUsers){
                    System.debug(t.name);
                }*/
                terrUsersMain.addAll(terrUsers);
            }
            getParent(parentTerritory);


        }


    }

    public void deleteAccountShare(id accId){
        List<AccountShare> accountShares= [SELECT id FROM AccountShare WHERE AccountId=:accId];
        System.debug(accountShares);
        delete accountShares;
    }
}
//