/**
 * Created by LanaPC on 10.07.2016.
 */

public with sharing class SharingTriggerHandler {

    private List<User> users;
    private List<territory__c> subTerritories;
    private Map<Id, List<Id>> userToTerritoryMap;
    private List<TerrUser__Share> terrUserShareList;
    private List<Territory__Share> terrShareList;
    private List<AccountShare> accSharesList;
    private List<Reference__Share> refShareList;
    private List<ContactShare> conShareList;
    private Map<Id,list<Territory__c>> parToChidTerrsMap;
    private List<Territory__c>  AllTers;


    public SharingTriggerHandler() {
        subterritories = new List<Territory__c>();
        users = new List<User>();
        List<Territory__c> emptyList = new List<Territory__c>();
        userToTerritoryMap = new Map<Id, List<Id>>();
        terrUserShareList = new List<TerrUser__Share>();
        terrShareList = new List<Territory__Share>();
        accSharesList = new List<AccountShare>();
        refShareList = new List<Reference__Share>();
        conShareList = new List<ContactShare>();
        AllTers=[SELECT id,name, (SELECT id,name FROM childTerritorys__r)FROM Territory__c];
        for(Territory__c rr:AllTers){
            System.debug('id :'+rr.id+ ' '+ rr.name );
        }
        parToChidTerrsMap=new Map<id,List<Territory__c>>();
        for(Territory__c r:AllTers){
            parToChidTerrsMap.put(r.id,r.childTerritorys__r);

        }

//
    }

    public void launchSharing(Id user ) {
        List<TerrUser__c> terrUsers = [SELECT name, Territory__r.name, Territory__r.id, User__r.name, User__r.id
        FROM TerrUser__c WHERE user__r.Id=:user];

        for (TerrUser__c t: terrusers) {
            setTerrUserrShring(t,t.user__r.id);
            //для каждого юзера из терюзер создаем  мапу где ключь - айди юзера
            // value - список всех его терриорий
            List<Id> toMapTerritories = new List<Id>();

            if(userToTerritoryMap.containsKey(t.user__r.Id)){
                toMapTerritories = userToTerritoryMap.get(t.user__r.id);
            }


            toMapTerritories.add(t.Territory__r.Id);
            List<Territory__c> subTerritories = [
                    SELECT id, name
                    FROM Territory__c
                    WHERE ParenTerritory__r.id = :t.Territory__r.id
            ];
            // рекурсивно достаем все терриории, елси подтерриории из терюзер не налл, т.е. если єто не город

            If (subTerritories.size() != 0) fillTerritoryForCurentUser( subTerritories,   toMapTerritories );
            //заносим в мапу
            userToTerritoryMap.put(t.user__r.Id,toMapTerritories);

            System.debug(t.user__r.name + ' :'+t.name+ ' :'+ userToTerritoryMap.get(t.user__r.Id));
            System.debug(userToTerritoryMap.get(t.user__r.id).size());

        }
        setTerritorySharing();
        setAccountsSharing();
        setContactsSharing();
        updateSharing();

    }


    public void fillTerritoryForCurentUser(List<Territory__c> terrs, List<String>  toMapTerritories ){

        for (Territory__c t: terrs) {
            toMapTerritories.add(t.Id);
            subTerritories=parToChidTerrsMap.get(t.id);
            //
          /*  List<Territory__c> subTerritories = [
                                                SELECT id, name
                                                FROM Territory__c
                                                WHERE ParenTerritory__r.id = :t.id
                                                ];*/
           /* if(subTerritories.size()==null){
                return;
            }else*/ fillTerritoryForCurentUser(subTerritories,  toMapTerritories );

        }

    }
    public void  setTerrUserrShring(TerrUser__c t, Id userId){
        TerrUser__Share terrUserShr = new TerrUser__Share();
        terrUserShr.RowCause = Schema.TerrUser__Share.RowCause.Manual;
        terrUserShr.ParentId = t.Id;
        terrUserShr.UserOrGroupId = userId;
        terrUserShr.AccessLevel = 'Read';
        TerrUser__c rrr = [Select id,name from TerrUser__c where id=:t.id];
        System.debug('id '+ rrr.id  + rrr.name);

        terrUserShareList.add(terrUserShr);

    }
    public void  setTerritorySharing(){

        Set<id> usersId=userToTerritoryMap.keySet();
        for(Id idUser:usersId){
            for(Id terrId: userToTerritoryMap.get(idUser)){
                Territory__Share terrShr = new Territory__Share();
                terrShr.ParentId = terrid;
                terrShr.UserOrGroupId = idUser;
                terrShr.AccessLevel = 'Read';

                terrShareList.add(terrShr);

            }
        }

    }

    public void  setAccountsSharing(){

        Set<id> usersId=userToTerritoryMap.keySet();
        for(Id idUser:usersId){
            for(Id terrId: userToTerritoryMap.get(idUser)){
                List<Account> accs = [SELECT name,Id FROM Account
                WHERE territory__r.id=:terrId];
                if(accs.size()!=0){
                    for(Account ac:accs){
                        AccountShare accShare =new AccountShare();
                        accShare.AccountId=ac.Id;
                        accShare.UserOrGroupId = idUser;
                        accShare.OpportunityAccessLevel='none';
                        accShare.AccountAccessLevel = 'Read';
                        accSharesList.add(accShare);
                    }
                }


            }
        }


    }

    public void  setContactsSharing(){
        List<Territory__c> allTerritories=[SELECT id,name,(SELECT id,name from Accounts__r) from Territory__c];
        Map<Id,List<Account>> territoryMap = new Map<Id,List<Account>>();
        for(Territory__c tr:allTerritories){

            territoryMap.put(tr.id,tr.Accounts__r);

        }

        List<Account> allAccounts=[SELECT id,name,(SELECT id,name,Contact__r.Id,Account__r.Id from Reference__r) from Account];
        Map<Id,List<Reference__c>> referenceMap = new Map<Id,List<Reference__c>>();
        for(Account an:allAccounts){

            referenceMap.put(an.id,an.Reference__r);

        }
//

        list<Account> relatedToUserAccounts = new List<Account>();
        list<Reference__c> relatedToAccountReferences = new List<Reference__c>();
        Set<id> usersId=userToTerritoryMap.keySet();
        for(Id idUser:usersId){
            for(Id terrId: userToTerritoryMap.get(idUser)) {
                relatedToUserAccounts = territoryMap.get(terrId);

             /*   List<Account> accs = [SELECT name,Id FROM Account
                WHERE territory__r.id=:terrId];*/
                if(relatedToUserAccounts!=null){
                if (relatedToUserAccounts.size() != 0) {
                    for (Account ac:relatedToUserAccounts) {
                        relatedToAccountReferences = referenceMap.get(ac.Id);
                      /*  List<Reference__c> refs=[SELECT id,name,Contact__r.Id FROM Reference__c
                                               WHERE Account__r.id=:ac.Id];*/
                        if(relatedToAccountReferences!=null){
                        if (relatedToAccountReferences.size() != 0) {
                            for (Reference__c r: relatedToAccountReferences) {
                                Reference__Share refShare = new Reference__Share();
                                ContactShare conShare = new ContactShare();

                                conShare.ContactId = r.Contact__r.Id;
                                conShare.UserOrGroupId = idUser;
                                conShare.ContactAccessLevel = 'read';
//////////////
                                refShare.ParentId = r.id;
                                refShare.UserOrGroupId = idUser;
                                refShare.AccessLevel = 'read';

                                refShareList.add(refShare);
                                conShareList.add(conShare);
                            }
                        }
                    }


                    }
                }
            }


            }
        }
    }

    public void updateSharing(){
        try {
            upsert terrShareList;
            User u = [SELECT id,name FROM User WHERE name =:'harkkievreg User'];
            System.debug('User name:' + u.name + ' id:'+ u.id);
            System.debug('teruser shares: '+ terrShareList);//
            upsert terrUserShareList;
            upsert accSharesList;
            upsert conShareList;
            upsert refShareList;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    public  void deleteAllAccess(Id user) {
        List<ContactShare> contactShares = [SELECT id,ContactId,UserOrGroupId FROM ContactShare WHERE UserOrGroupId = :user];
        delete contactShares;

        List<Reference__Share> referencesShares = [SELECT id FROM Reference__Share WHERE UserOrGroupId = :user AND RowCause = 'Manual'];
        delete referencesShares;

        List<AccountShare> accountShares = [SELECT id,AccountId,UserOrGroupId FROM AccountShare WHERE UserOrGroupId = :user AND RowCause = 'Manual'];
        delete accountShares;

        List<Territory__Share> terrsShares = [SELECT id FROM Territory__Share WHERE UserOrGroupId = :user AND RowCause = 'Manual'];
        delete terrsShares;

        List<TerrUser__Share> TeerUserShares = [SELECT id FROM TerrUser__Share WHERE UserOrGroupId = :user AND RowCause = 'Manual'];
        delete TeerUserShares;


    }
}