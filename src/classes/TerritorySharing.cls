/**
 * Created by LanaPC on 08.07.2016.
 */

public with sharing class TerritorySharing {
    private List<User> users;
    private List<territory__c> subTerritories;
    private Map<Id, List<Id>> userToTerritoryMap;
    private List<TerrUser__Share> terrUserShareList;
    private List<Territory__Share> terrShareList;


    public TerritorySharing() {
        subterritories = new List<Territory__c>();
        users = new List<User>();
        List<Territory__c> emptyList = new List<Territory__c>();
        userToTerritoryMap = new Map<Id, List<Id>>();
        terrUserShareList = new List<TerrUser__Share>();
        terrShareList = new List<Territory__Share>();

    }

    public void launchSharing() {
        List<TerrUser__c> terrUsers = [SELECT name, Territory__r.name, Territory__r.id, User__r.name, User__r.id
                                       FROM TerrUser__c];

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

            If (subTerritories.size() != null) fillTerritoryForCurentUser( subTerritories,   toMapTerritories );
            //заносим в мапуі
            userToTerritoryMap.put(t.user__r.Id,toMapTerritories);
            System.debug(t.user__r.name + ' :'+t.name+ ' :'+ userToTerritoryMap.get(t.user__r.Id));
            System.debug(userToTerritoryMap.get(t.user__r.id).size());

        }
        setTerritorySharing( userToTerritoryMap);
        updateSharing(terrUserShareList, terrShareList);

    }

    public void fillTerritoryForCurentUser(List<Territory__c> terrs, List<String>  toMapTerritories ){

        for (Territory__c t: terrs) {
            toMapTerritories.add(t.Id);
            List<Territory__c> subTerritories = [
                                                SELECT id, name
                                                FROM Territory__c
                                                WHERE ParenTerritory__r.id = :t.id
                                                ];
            if(subTerritories.size()==null){
                return;
            }else fillTerritoryForCurentUser(subTerritories,  toMapTerritories );

        }

    }
    public void  setTerrUserrShring(TerrUser__c t, Id userId){
        TerrUser__Share terrUserShr = new TerrUser__Share();
        terrUserShr.ParentId = t.Id;
        terrUserShr.UserOrGroupId = userId;
        terrUserShr.AccessLevel = 'Read';

        terrUserShareList.add(terrUserShr);

    }
    public void  setTerritorySharing(Map<Id, List<Id>> userToTerritoryMap){

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

    public void  setAccountsSharing(Map<Id, List<Id>> userToTerritoryMap){

       

    }

    public void updateSharing( List<TerrUser__Share> terrUserShareList,List<Territory__Share> terrShareList){
        try {
            upsert terrShareList;
            upsert terrUserShareList;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }


}