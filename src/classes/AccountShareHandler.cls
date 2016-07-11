/**
 * Created by LanaPC on 10.07.2016.
 */

public with sharing class AccountShareHandler {
    public List<TerrUser__c> terrUsersMain;
    public List<AccountShare> accShareList;

    public AccountShareHandler() {
        terrUsersMain = new List<TerrUser__c>();
        accShareList = new List<AccountShare>();
    }
    public void handlleAccountShare(Account acc) {
        System.debug(acc.name);
        System.debug(acc.Territory__c);
        Territory__c terr = [SELECT id, name, ParenTerritory__r.Id FROM Territory__c WHERE id = :acc.Territory__c];
        System.debug(terr.name);
        List<TerrUser__c> terrUsers = [SELECT id, name, user__r.id FROM TerrUser__c WHERE Territory__r.id = :acc.Territory__c];
        if (terrUsers.size() != 0) {


            terrUsersMain.addAll(terrUsers);
        }

        getParent(terr);

        System.debug(terrUsersMain.size());
        if (terrUsersMain.size() != 0) {
            for (TerrUser__c t: terrUsersMain) {
                System.debug('terruser name'+ t.name);
            }
        }

        if (terrUsersMain.size() != 0) {
            for (TerrUser__c t: terrUsersMain) {
                SharingTriggerHandler sharinghandler = new SharingTriggerHandler();
                sharinghandler.deleteAllAccess(t.user__r.id);
//
            }

        }

    }

    public void handlleAccountShareAfter(Account acc) {
        System.debug(acc.Territory__r.id);

        //ter of current account
        Territory__c terr = [SELECT id, name, ParenTerritory__r.Id FROM Territory__c WHERE id = :acc.Territory__c];

        List<TerrUser__c> terrUsers = [SELECT id, name, user__r.id FROM TerrUser__c WHERE Territory__r.id = :acc.Territory__c];
        if (terrUsers.size() != 0) {
            for (TerrUser__c t: terrUsers) {
                System.debug(t.name);
            }
            terrUsersMain.addAll(terrUsers);
        }

        getParent(terr);

        System.debug(terrUsersMain.size());
        if ( terrUsersMain.size() != 0) {
            for (TerrUser__c t: terrUsersMain) {
                System.debug('After '+t.name);
            }
        }

        if (terrUsersMain.size() != 0) {
            for (TerrUser__c t: terrUsersMain) {

                SharingTriggerHandler sharinghandler = new SharingTriggerHandler();

                sharinghandler.launchSharing(t.user__r.id);


            }

        }


    }
    public void getParent(Territory__c terr) {
        List<TerrUser__c> terrUsers = new List<TerrUser__c>();
        if (terr.ParenTerritory__r.id != null) {
            Territory__c parentTerritory = [SELECT id, name, ParenTerritory__r.Id FROM Territory__c WHERE id = :terr.ParenTerritory__r.id];
            terrUsers = [SELECT id, name, user__r.id FROM TerrUser__c WHERE Territory__r.id = :parentTerritory.id];
            if (terrUsers.size() != 0) {

                terrUsersMain.addAll(terrUsers);
            }
            getParent(parentTerritory);


        }


    }

    public void deleteAccountShare(id accId) {
        List<AccountShare> accountShares = [SELECT id FROM AccountShare WHERE AccountId = :accId];
        System.debug(accountShares);
        delete accountShares;
    }
}
