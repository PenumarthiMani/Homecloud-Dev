// Test Class - SendScenarioPrintControllerTest
public class SendScenarioPrintController 
{
    //variable declaration
    public Scenario__c q{set;get;}
    public String subject{set;get;}
    public String toAddress{set;get;}
    public String ccAddress{set;get;}
    public String body{set;get;}
    
    //constructor
    public SendScenarioPrintController()
    {
        String quoteId = Apexpages.currentpage().getparameters().get('Id');
        q = [SELECT Id FROM Scenario__c WHERE Id =: quoteId];
      //  toAddress = q.Account.PersonEmail; 
       
    }
    
    //method to send email
    public PageReference sendEmail()
    {
                 
        //validating subject,to addresses
        if(String.isBlank(subject))
        {
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Subject.'));
            return null;
        }
        else if(String.isBlank(toAddress))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter To Address.'));
            return null;
        }
        
        //preparing attachment
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.fileName = 'Scenario.pdf';
        efa.body = Test.isRunningTest() ? Blob.valueOf('Test') : new PageReference('/apex/SelectionReport?qid='+q.Id).getContentAsPDF();
        
         
        
        //Sending email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        //setting to address        
        if(String.isNotBlank(toAddress))
        {
            list<String> toAddresses = new list<String>();
            toAddresses = toAddress.split(',');
            mail.setToAddresses(toAddresses);
        }
        
        //setting cc address
        if(String.isNotBlank(ccAddress))
        {
            list<String> ccAddresses = new list<String>();
            ccAddresses = ccAddress.split(',');
            mail.setCcAddresses(ccAddresses);
        }
        
        //setting subject
        mail.setSubject(subject);
        
        //setting body
        mail.setHtmlBody(body);
        
        //setting attachments
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{efa});
        
        //sending email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        PageReference pg = new PageReference('/'+q.Id);
        pg.setRedirect(true);
        return pg;
    }
    
    //callback method for cancel button.
    public PageReference cancel()
    {
        PageReference pg = new PageReference('/'+q.Id);
        pg.setRedirect(true);
        return pg;
    }    
}