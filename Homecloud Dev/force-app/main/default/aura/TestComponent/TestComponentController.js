({
    doInit : function (component, event, helper) {
        var action = component.get("c.RegRequired");
        action.setParams({
            "conId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var resultVal = response.getReturnValue();
                //component.set("v.hasError",resultVal.RegRequired);
                if(resultVal.hasError){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: resultVal.message,
                        duration:'500',
                        type: 'error',
                    });
                    toastEvent.fire();  
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
        });
        $A.enqueueAction(action);
        /*  
        var today = new Date();
        component.set('v.today', today.getFullYear() + "-" + (today.getMonth() +4) + "-" + today.getDate());
         */ 
        
        var action = component.get("c.getRecTypeId");
        action.setParams({
            "recordTypeLabel" : "Regular"
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var resultVal = response.getReturnValue();
                component.set("v.QuoteRecordType",resultVal);
            }
        });
        $A.enqueueAction(action);
        
        var action = component.get("c.dogetfieldsetfields");
        action.setParams({
            "conId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state3 = response.getState();
            if(state3 === "SUCCESS"){ 
                var resultVal3 = response.getReturnValue();
                component.set('v.allfieds',resultVal3);
            }
        });
        $A.enqueueAction(action);
    },
    onSubmit : function(component, event, helper) {
        console.log(component.get("v.simpleconnection.Division__c"));
        component.set("v.Spinner",true); 
        event.preventDefault();
        var fields = event.getParam("fields");
        fields["Target_Closing_Date__c"] =component.find("datefield").get("v.value");
        component.find("editForm").submit(fields);
    },
    handleSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'Scenario has been created successfully!',
            duration:'500',
            type: 'success',
        });
        toastEvent.fire();
        var params = event.getParams();
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": params.response.id
        });
        navEvt.fire();
    },
    handleCancel : function(component, event, helper) {
        event.preventDefault();
        $A.get("e.force:closeQuickAction").fire();
    },
    errorInformation : function(component, event, helper) {
        var eventName = event.getName();
        var eventDetails = event.getParams().error.message;
    },
    load : function(component, event, helper){
        var s = component.get("v.simpleconnection.Estimated_Close_Date__c");
        component.set("v.today",s);
    }
})