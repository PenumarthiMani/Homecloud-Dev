({
    doInit : function(component,event,helper){
        window.setTimeout(
            $A.getCallback(function() {
                var objectInfo = component.get("v.simpleRecord");  console.log('objectInfo:'+JSON.stringify(objectInfo).Id);
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
            }), 500
        );
        
        component.set('v.allfieds',[]); 
        var fieldsetfields=component.get('c.dogetfieldsetfields');
        fieldsetfields.setCallback(this,function(resp){
            var state=resp.getState();
            if(state==='SUCCESS'){
                var resul=resp.getReturnValue();
                var listOptions = [];
                for(var i=0; i <resul.length; i++){
                    listOptions.push(resul[i]);
                } 
                component.set('v.allfieds',listOptions); 
            }
        }); 
        $A.enqueueAction(fieldsetfields); 
    },
    onsubmitaction : function(component,event,helper){
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD")
        event.preventDefault();
        var eventFields = event.getParam("fields");
        if(today >= eventFields["Date__c"]){
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