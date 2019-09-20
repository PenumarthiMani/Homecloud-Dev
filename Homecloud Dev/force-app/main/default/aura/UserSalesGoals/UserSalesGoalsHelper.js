({
    userYearChange : function(component, event, us, year){
        var action = component.get("c.turboList");
        var usId = component.get("v.userId");
        var yearChange = component.get("v.yearChange");
        action.setParams({userId : usId, year : year});
        action.setCallback(this, function(response){
            
            var state = response.getState();
            
            if(state==='SUCCESS')
            {
                component.set("v.turboGoalList" , response.getReturnValue());  
            } 
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
    },
    saveMethod : function(component, event, turbList){
        var action = component.get("c.turboListSave");
        action.setParams({ turboList : turbList});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state==='SUCCESS')
            {
                component.set("v.turboGoalList" , response.getReturnValue());
            }
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
        
    }
})