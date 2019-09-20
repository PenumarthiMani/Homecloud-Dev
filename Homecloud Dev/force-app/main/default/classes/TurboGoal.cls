public class TurboGoal {
    @AuraEnabled 
    public static List<Sales__c> turboList(String userId, string year)
    {
        system.debug('@@@');
        List<Sales__c> turboList = New List<Sales__c>();
        Integer decSelectedYear = Integer.valueof(year);
        List<Sales__c> turboRecords = [Select Id, External_Id__c, Actuals__c, Date__c,Profile__c, Goal__c,User__c, Name_of_the_Month__c from Sales__c where User__c = :userId and Year__c = :decSelectedYear]; 
        
        Map<string, Sales__c> turboRecordMap = new Map<string, Sales__c>();
        
        for(Sales__c s : turboRecords){
            turboRecordMap.put(s.External_Id__c, s);
        }
        for(Integer i = 1; i <= 12; i++){
            dateTime dTime = DateTime.newInstance(decSelectedYear, i, 1, 0, 0, 0);
            Date dt = Date.newInstance(decSelectedYear, i, 1);
            String dtMonth = string.valueof(dTime.format('MMMMM'));
            String extenalId = userId+'-'+dTime.format('MMM-YYYY');
            if(turboRecordMap.containsKey(extenalId)){
                turboList.add(turboRecordMap.get(extenalId));
            }
            else{
                
                turboList.add(new Sales__c(OwnerId = userId, External_Id__c = extenalId, User__c = userId, Goal__c = 0, Actuals__c = 0, Date__c = dt, Name_of_the_Month__c = dtMonth));
            }
        }
        
        return turboList;
    }
    
    @AuraEnabled
    public static List<Sales__c> turboListSave(List<Sales__c> turboList)
    { 
        if(!turboList.IsEmpty())
        upsert turboList;
        return turboList;
    }
     @AuraEnabled
    public static String fetchUser()
    {
      // query current user information  
      User lUser = [select id,Name FROM User Where id =: userInfo.getUserId() limit 1];
        return lUser.Id;
    }
     @AuraEnabled
    public static List<picklistWrap> currentyear()
    {
       List<picklistWrap> Type = new List<picklistWrap>();
        integer year = System.today().year() -3 ;
        for(integer i=0;i<=6;i++){
            Type.add(new picklistWrap(string.valueof(year), string.valueof(year)));
            year = year+1;
        }
       
       return Type;
    }
    public class picklistWrap {
        @AuraEnabled public string labelval;
        @AuraEnabled public string selectedVal;
        public picklistWrap(string labelval, string selectedVal)
        {
            this.labelval = labelval;
            this.selectedVal = selectedVal;
        }
    }   
}