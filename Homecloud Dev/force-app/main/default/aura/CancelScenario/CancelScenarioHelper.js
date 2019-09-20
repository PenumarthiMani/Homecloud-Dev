({
	ScenarioDetail : function(component, event) {
        var useraction = component.get("c.selectedScenario");        
        useraction.setParams({"recordId" : component.get("v.recordId")});
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var resultVal = response.getReturnValue();
                component.set("v.scenarioDetails",resultVal);
            }
        });
        $A.enqueueAction(useraction);    
	},
    CancelTypes : function(component, event) {
        var useraction = component.get("c.getCancelTo");
            useraction.setCallback(this, function(response){
                if(response.getState()==="SUCCESS" && component.isValid()){
                    component.set("v.Cancel",response.getReturnValue());
                }
            });
         $A.enqueueAction(useraction);	
	},
    CancelScenario : function(component, event) {
        var useraction = component.get("c.cancelScenario");        
        useraction.setParams({"scenarioDetails" : component.get("v.scenarioDetails")});
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var resultVal = response.getReturnValue();
                component.set("v.isOpen", false);
                var resultId= resultVal.includes("Success")? resultVal.split('-')[1] : '';
   			if(resultVal.includes("Success"))
                {
                    this.showSuccessToast(component,event,"Successfully Cancelled the Scenario");
                    //$A.get('e.force:refreshView').fire();
                    if(resultId!=''){
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": resultId
                        });
                        navEvt.fire();
                    }
                    
                }
                else
                {
                    this.showErrorToast(component,event,"Something went wrong");
                }    
                
   			}
        });
        $A.enqueueAction(useraction);    
	},
    // this function is to show the error message
    showErrorToast : function(component, event, Message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "type": "error",
            "message": Message
        });
        toastEvent.fire();
    },
    // this function is to show the success message
    showSuccessToast : function(component, event, Message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": "success",
            "message": Message
        });
        toastEvent.fire();
    }
})