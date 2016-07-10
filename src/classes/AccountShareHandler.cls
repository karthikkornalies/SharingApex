/**
 * Created by LanaPC on 10.07.2016.
 */

public with sharing class AccountShareHandler {

    public void handlleAccountShare(Id accId){
        //inserted accoutn
        Account acc =[SELECT id,name, Territory__r.Id FROM Account WHERE id=:accId];
       System.debug(acc.Territory__r.id);

        //ter of current account
        Territory__c terr = [SELECT id,name, ParenTerritory__r.Id FROM Territory__c WHERE id=:acc.Territory__r.Id];

        List<TerrUser__c> terrUsers = [SELECT id,name,user__r.id FROM TerrUser__c WHERE Territory__r.id=:acc.Territory__r.Id ];
        if (terrUsers.size()!=0){
            for(TerrUser__c t: terrUsers){
                System.debug(t.name);
            }

        }else getParent(terr);

    }
    public void getParent(Territory__c terr){
        List<TerrUser__c> terrUsers = new List<TerrUser__c>();
        if(terr.ParenTerritory__r.id!=null){
            Territory__c parentTerritory = [SELECT id,name FROM Territory__c WHERE id=:terr.ParenTerritory__r.id];
             terrUsers = [SELECT id,name,user__r.id FROM TerrUser__c WHERE Territory__r.id=:parentTerritory.id];
        }
        if(terrUsers.size()!=0){
            for(TerrUser__c t: terrUsers){
                System.debug(t.name);
            }
        }

    }
}