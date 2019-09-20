({
   doinit : function(component, event, helper) { 
        helper.scenarioDetail(component,event);  
   },
   selectionReport : function(component, event, helper) { 
        var scenarioId = component.get("v.recordId");
        window.open('/' + "apex/PrintScenarioEmail?Id="+scenarioId,'_blank');
   },
   sendWithDocusign : function(component, event, helper) { 
        var scenarioId = component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/DocuSign?id="+scenarioId
        });
        urlEvent.fire();  
   }, 
})