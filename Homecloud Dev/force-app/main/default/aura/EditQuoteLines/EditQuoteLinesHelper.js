({
	scenarioDetail : function(component, event) {
        var useraction = component.get("c.selectedScenario");    
        useraction.setParams({"recordId" : component.get("v.recordId")});
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var resultVal = response.getReturnValue();
                component.set("v.ScenarioDetails",resultVal);
                if(resultVal.Status__c != 'Cancelled'){
                    component.set("v.showFOrm",true);
                }
            }
        });
        $A.enqueueAction(useraction);    

    }
})