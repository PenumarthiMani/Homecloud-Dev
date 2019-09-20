public without sharing class Recursive{
    //Used in ConnectionTriggerHandler and QuoteTriggerHandler classes
    public static boolean stopOppUpdateStageTrigger = true;
    
    //Used in LeadConversion and CreateOpportunityOnAccount triggers
    public static boolean leadRecursive = true;
    
    //Used in ConnectionTriggerHandler,LeadConversion class 
    public static boolean oppRun = true;
    
      //Used in ConnectionTriggerHandler,LeadConversion class 
    public static boolean oppUpdateRun = false;
    
    public static boolean accScoreRun = false;
    
    //Used in CreateOpportunityOnAccount Trigger 
    public static boolean accUpdate = false;
    
    public static boolean oppUpdatedFromForm =false;
}