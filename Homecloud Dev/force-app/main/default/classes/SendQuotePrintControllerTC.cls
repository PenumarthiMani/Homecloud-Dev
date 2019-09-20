@IsTest()
Public Class SendQuotePrintControllerTC{
    
    public static testmethod void SendQuotePrintControllermethod(){
    
      Id Hbrecordtype = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homebuyer').getRecordTypeId();
      List<Contact> con=TestDataUtil.createContact(1,Hbrecordtype);
      con[0].Type__c='Lead';        
      insert con;
    
      Connection__c op = New Connection__c();
      op.Name = 'Test Opportunity';
      op.Status__c = 'Lead';
      op.Homebuyer__c=con[0].id;
      //op.CloseDate = System.Today();
      Insert op;
      
      Scenario__c qo = New Scenario__c();
      //qo.Name = 'Test Quote';
      qo.Connection__c= op.Id;
      Insert qo;
      
      ApexPages.currentPage().getParameters().put('Id',qo.id);
      
      SendScenarioPrintController SQPC = new SendScenarioPrintController ();
      SQPC.ccAddress='test@gmail.com';
      SQPC.sendEmail();
      SQPC.body='test Body';
      SQPC.cancel();
      
      SQPC.subject = 'test';
      SQPC.sendEmail();
      
      
      SQPC.toAddress='test@gmail.com';  
      SQPC.sendEmail();

    }
    
}