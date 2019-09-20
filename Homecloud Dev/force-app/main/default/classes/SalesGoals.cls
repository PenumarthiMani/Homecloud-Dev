Public without sharing Class SalesGoals
{
    
    Public List<Sales__c> SalesList{get;set;}
    public String selectedYear { get; set;}
    public string selectedUser { get; set; }
    public boolean toShowInputFields { get; set; }
    public List<User> UserTemp = new List<User>();
    /********** To display user list start***************/
   /* public List<SelectOption> UserList
    {
        get
        {
            string userTypeStr = 'Standard';
            boolean isAcive = true;
            UserTemp = [select id, Profile.Name, Name from user where isActive = :isAcive and userType=:userTypeStr ORDER BY Name ASC];
            UserList = new List<SelectOption>();
            for(User temp : UserTemp)
            {
                UserList.add(new SelectOption(temp.Id, temp.Name));
            }
            return UserList;
        }
        set;
    } */
    
    /************** To add years dynamically******************/
    public List<SelectOption> getYears() {
        List<SelectOption> options = new List<SelectOption>();
        for (Integer i = System.Today().year() - 3; i < System.Today().year() + 4; i++) {
            options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        return options;
    }
    /********** To display user list end***************/
    //Constructor
    Public salesGoals()
    {
         SalesList = New List<Sales__c>();
         selectedYear = String.valueOf(System.Today().year());
         selectedUser = UserInfo.getUserId();
         searchSales();
    }
    
    public void searchSales() {
       Integer decSelectedYear = Integer.valueof(selectedYear);
       set<string> salesDupCheck = new set<String>();
       SalesList = [Select Id, External_Id__c, Actuals__c, Date__c, Division__c, Profile__c, Goal__c, User__c from Sales__c where User__c = :selectedUser and Year__c = :decSelectedYear]; 
       for(Sales__c ss : SalesList){
           salesDupCheck.add(ss.External_Id__c);
       }
       for(Integer i = 1; i <= 12; i++){
           dateTime dTime = DateTime.newInstance(decSelectedYear, i, 1, 0, 0, 0);
           Date dt = Date.newInstance(decSelectedYear, i, 1);
           String extenalId = selectedUser+'-'+dTime.format('MMM-YYYY');
           if(!salesDupCheck.contains(extenalId)){
             SalesList.add(new sales__c(OwnerId = selectedUser, External_Id__c = extenalId, User__c = selectedUser, Goal__c = 0, Actuals__c = 0, Date__c = dt));
           }
       }
    } 
    public void editMethod(){
       toShowInputFields = true;
    }
    public pageReference saveMethod(){
      upsert SalesList;
      toShowInputFields = false;
      return null;
    }
    public void cancelMethod(){
      toShowInputFields = false;
      searchSales();
    }
    
    @RemoteAction
    public static List<User> getUsers(String keyword) {
        List<User> users = new List<User>();
        if (string.isNotBlank(keyword)) {
            keyword = '%' + String.escapeSingleQuotes(keyword) + '%';
            users = [Select Id, Name from User where Name like :keyword limit 5];
        }
        return users;
    }
    @RemoteAction
    public static User getCurrentUserInfo() {
        user usr = new user();

            usr = [Select Id,Name from User where ID=: UserInfo.getUserId() limit 1];
            usr = usr==null ? new user() : usr;
        return usr;
    }
    
}