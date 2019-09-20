({	
    handlelookupEvent :function(component, event, helper) {
        helper.getlookupids(component, event, helper); 
    },
    closeaction :function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
        dismissActionPanel.fire(); 
    },
    handleSave :function(component, event, helper) {
        helper.saveRecs(component, event, helper);
    },
    doInit : function(component, event, helper){
        var contactrecordid = component.get("v.recordId");
        var action = component.get("c.recordname");
        action.setParams({"contactid" : contactrecordid});
        action.setCallback(this,function(a){
           var state = a.getState();
            if(state == "SUCCESS"){
                component.set("v.conId",a.getReturnValue());
            }
            else{
                var toastmesg = $A.get("e.force:showToast");
                toastmesg.setParams({
                    "title": "Error!",
                        "type": 'Error',
                        "message": "Something went wrong."
                });
                toastmesg.fire();
            }
        });
        $A.enqueueAction(action);
    }
})