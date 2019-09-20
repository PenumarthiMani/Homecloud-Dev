({
    doInit : function(component,event,helper){
        window.setTimeout(
            $A.getCallback(function() {
                var objectInfo = component.get("v.simpleRecord");
                if(objectInfo.Status__c == 'Closed Won'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": 'error',
                        "message": "Reg card will create only under Lead Status."
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
                else{
                    var cmpTarget = component.find('showForm');
                    $A.util.removeClass(cmpTarget, 'slds-hide');
                    component.set("v.showSpinner",false);
                }
               
                var existingDate = component.get("v.simpleRecord.Date__c");
                if(existingDate ==  null){
                    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                    component.set('v.today', today);
                }
                else{
                    component.set('v.today', existingDate); 
                    
                }
            }), 500
        );
    },
    onsubmitaction : function(component,event,helper){
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD")
        event.preventDefault();
        var eventFields = event.getParam("fields");
        var minval=eventFields["Price_Range_Min__c"];
        var maxval=eventFields["Price_Range_Max__c"];
        eventFields["Date__c"] = component.get("v.today");
        if(minval>maxval){
            component.find('notifLib').showToast({
                "title": "Error!",
                "variant":"error",
                "message": "Min Price Should Not be more than Max Price"
            });
        }
        else if(today >= component.get("v.today")){
            component.find('recordEditForm').submit(eventFields);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": 'error',
                "message": "Date should not be greater than today"
            });
            toastEvent.fire();   
        }        
    },
    handleSuccess:function(component){
        var action=component.get('c.doRegCard');
        action.setParams({
            'opp':component.get('v.recordId')
        });
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==='SUCCESS'){
                component.find('notifLib').showToast({
                    "title": "Success!",
                    "variant":"success",
                    "message": response.getReturnValue()
                });
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
    cancel :function(component){
        $A.get("e.force:closeQuickAction").fire();   
    }
    
})