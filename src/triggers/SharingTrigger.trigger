/**
 * Created by LanaPC on 10.07.2016.
 */

trigger SharingTrigger on TerrUser__c (after insert, after update, after delete) {

    if(Trigger.isInsert) {
        System.debug('insert trigger');
        for(TerrUser__c terrUser: Trigger.new) {
            new SharingTriggerHandler().launchSharing(terrUser.User__c);

        }

    }
//
    if(Trigger.isUpdate) {
        System.debug('update trigger');
        for(TerrUser__c terrUser: Trigger.new) {
            new SharingTriggerHandler().deleteAllAccess(terrUser.User__c);
            new SharingTriggerHandler().launchSharing(terrUser.User__c);
        }


    }

    if(Trigger.isDelete) {
        System.debug('delete trigger');
       for(TerrUser__c terrUser: Trigger.old) {
           new SharingTriggerHandler().deleteAllAccess(terrUser.User__c);
           new SharingTriggerHandler().launchSharing(terrUser.User__c);
        }

    }
}