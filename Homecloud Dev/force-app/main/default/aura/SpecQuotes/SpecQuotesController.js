({
	doinit : function(component, event, helper) { 
		helper.quoteDetail(component,event);
        helper.DivisionValues(component,event);
    },
    doSearch : function(component, event, helper) { 
		helper.quoteDetail(component,event);
    },
    Divisionfilter : function(component, event, helper) { 
        helper.CommunityValues(component,event);
    },
    openModel: function(component, event, helper) {
      component.set("v.isOpen", true);
   },
   closeModel: function(component, event, helper) {
       component.set("v.isOpen", false);
   },
   InsertSpec: function(component, event, helper) {
       var communityId = component.get("v.CommunityId");
       var DivisionId = component.get("v.DivisionId");
       if($A.util.isEmpty(communityId) || $A.util.isEmpty(communityId))
       {
        	helper.showErrorToast(component,event,'Community and Division are required');  
       }
       else
       {
       		helper.InsertSpec(component,event);
       }
       
   }, 
   lookupEvent: function(component, event, helper) {
       if(event.getParam("sobjectType") == 'Division__c'){
           var divId = event.getParam("lookuprecordId");
           component.set("v.DivisionId",divId);
           if($A.util.isEmpty(divId))
           {
               var appEvent = $A.get("e.c:refreshchildLookup");
               appEvent.setParams({ "sobjectType" : 'jj' });
               appEvent.fire();
           }
       }
       else{
         component.set("v.CommunityId",event.getParam("lookuprecordId"));  
       }
   }  
})