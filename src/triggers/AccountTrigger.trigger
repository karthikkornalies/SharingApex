/**
 * Created by LanaPC on 10.07.2016.
 */

trigger AccountTrigger on Account (after insert, After update, after delete) {

    if(Trigger.isInsert) {

      for(Account acc:Trigger.new){
          new AccountShareHandler().handlleAccountShareAfter(acc);
      }

    }
//

    if(Trigger.isUpdate) {

        for(Account acc:Trigger.old){
            new AccountShareHandler().handlleAccountShare(acc);
        }
        new TerritorySharing().launchSharing();
    }

    if(Trigger.isDelete) {
        for(Account acc:Trigger.old){
            new AccountShareHandler().deleteAccountShare(acc.id);
        }

    }

}