public without sharing class UnregisteredTrafficController {
    @AuraEnabled
    public static string dogetRecordtypeid(){
        string recordTypeIdString = RecordTypeUtil.Trafficunregisteredrecordtypename();
        return recordTypeIdString;
    }

}