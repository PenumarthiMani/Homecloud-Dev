({
    fetchdata : function(component, event, helper) {
        var myid = component.get("v.recordId");
        var action = component.get("c.Incentivesfiltered");
        action.setParams({ "quoteid" : myid });
        action.setCallback(this,function(a){
            var state = a.getState();
            if(state == "SUCCESS"){
                var result = a.getReturnValue();
                if(result && result.length == 0 ){
                    component.set("v.isOpen",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'No active Incentives found',
                        duration:'500',
                        type: 'Information',
                    });
                    toastEvent.fire();
                    
                }else{
                    component.set("v.innerclassvalues",a.getReturnValue());
                    component.set("v.isOpen", true);
                }
                
            } else {
                
            }
        });
        
        
        $A.enqueueAction(action);
    },
    success : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: 'Scenario incentive has been created successfully!',
            duration:'500',
            type: 'success',
        });
        toastEvent.fire();
    },
    Error : function(component, event, Message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "type": "error",
            "message": Message,
        });
        toastEvent.fire();
    }
    
})