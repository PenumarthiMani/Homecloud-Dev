({
    doInit:function(component){ console.log('hiii');
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);
       // component.find('Traffic_Date__c').set('v.value', today);
        var action=component.get("c.dogetRecordtypeid");
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==='SUCCESS'){
                component.set('v.recordtypeid',response.getReturnValue());   
            }
        });
        $A.enqueueAction(action);
    }
    ,
    handleSuccess : function(component, event) {
        var payload = event.getParams().response;
        var navService = component.find("navService");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": payload.id,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    cancel :function(component, event){    
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Traffic__c"
        });
        homeEvent.fire();
    }    
})