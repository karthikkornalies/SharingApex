/**
 * Created by LanaPC on 10.07.2016.
 */

trigger AccountTrigger on Account (after insert, after update, after delete) {

    if(Trigger.isInsert) {

      for(Account acc:Trigger.new){
          new AccountShareHandler().handlleAccountShare(acc.id);
      }

    }
//

    if(Trigger.isUpdate) {
        for(Account acc:Trigger.new){
            new AccountShareHandler().handlleAccountShare(acc.id);
        }
    }

  /*  if(Trigger.isDelete) {
        for(Account acc:Trigger.old){
            new AccountShareHandler().handlleAccountShare(acc.id);
        }

    }*/

}