public class PrintScenarioEmailController
{ 
    public Scenario__c scenarioRecord{set;get;}
    public string scenarioid{get;set;}
    public PrintScenarioEmailController()
    {
        scenarioid = Apexpages.currentpage().getparameters().get('Id');
    } 
    
    public PageReference sendEmail()
    {
        PageReference pg = new PageReference('/apex/SendScenarioPrint?Id='+scenarioid);
        pg.setRedirect(true);
        return pg;
    }
}