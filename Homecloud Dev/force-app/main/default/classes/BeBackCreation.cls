/*
Description: Beback creation and validations
*/
Public without sharing Class BeBackCreation
{
 @AuraEnabled
    Public Static string createBeBack(String RecordId)
    {
        try
        {
            Id RegRecordType=RecordTypeUtil.trafficRegisteredRecordTypeName();
            Connection__c connection = New Connection__c();
            connection = [Select Id, Community__c,Status__c, (select Id, Createddate,Date__c from Traffic__r where RecordTypeId =: RegRecordType) from Connection__c where Id =: RecordId];
            if(!connection.Traffic__r.IsEmpty() ){
             if(connection.Status__c != 'Closed Won')
            {
                Traffic__c RegCard = New Traffic__c();
                RegCard = connection.Traffic__r[0];
                Connection__c connection1 = New Connection__c();
            connection1 = [Select Id, Community__c, (select Id from Traffic__r where RecordType.DeveloperName = 'Beback' and Date__c = Today) from Connection__c where Id =: RecordId];
                if(connection1.Traffic__r.IsEmpty() && RegCard.Date__c <> system.Today())
                {
                    Traffic__c Beback = New Traffic__c();
                     if(Schema.sObjectType.Traffic__c.fields.Community__c.isUpdateable())
                    Beback.Community__c = connection.Community__c;
                     if(Schema.sObjectType.Traffic__c.fields.Connection__c.isUpdateable())
                    Beback.Connection__c = connection.Id;
                     if(Schema.sObjectType.Traffic__c.fields.Count__c.isUpdateable())
                    Beback.Count__c = 1;
                    Beback.Date__c = system.Today();
                     if(Schema.sObjectType.Traffic__c.fields.RecordTypeId.isUpdateable())
                    Beback.RecordTypeId = RecordTypeUtil.trafficRecordTypeName();                   
                     if(Schema.sObjectType.Traffic__c.isCreateable())
                    Insert Beback;
                    return 'Success';
                }
                else
                {    
                    if(RegCard.Date__c== system.Today())
                        return 'Sorry, you can\'t create RegCard and BeBack on same day';
                    else
                        return 'Sorry, already BeBack has been created for today';
                }    
            }else{
                return 'Beback card will create only under Lead Status.';
            }
            }
            else
                return 'Sorry, you are not allowed to create a BeBack with out Registration Card';
        }
        catch(exception e)
        {
            return e.getMessage();
        }
    }
}