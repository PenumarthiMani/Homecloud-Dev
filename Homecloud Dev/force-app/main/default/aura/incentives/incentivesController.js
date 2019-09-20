({
    getvalues : function(component, event, helper) {
        //helper.fetchdata(component, event, helper);
    },
    
    doSomething : function(component, event, helper) {
        var action = component.get("c.save");
        var xx = component.get("v.innerclassvalues");
        if(!$A.util.isEmpty(xx) && !$A.util.isUndefined(xx)){
            var action = component.get("c.save");
            var positionRecords = JSON.stringify(xx);
            action.setParams({
                positionRecords : positionRecords
            });
            
            action.setCallback(this,function(a){
                var state = a.getState();
                if(state == "SUCCESS"){
                    
                    if(a.getReturnValue()=='success'){
                        component.set("v.isOpen", false);
                        $A.get('e.force:refreshView').fire();
                        helper.success(component, event, helper);
                        var cmpTarget = component.find('Modalbox');
                        
                    }
                    
                } else if(state == "ERROR"){
                    helper.Error(component, event, helper);
                   component.set("v.isOpen", false);
                }
            });      
            $A.enqueueAction(action);
            
        }
    },
    
    cancel : function(component, event, helper) {
        component.set("v.isOpen", false);
        
    },
    openmodal: function(component,event,helper) { 
        helper.fetchdata(component, event, helper);
        
        
    }
})