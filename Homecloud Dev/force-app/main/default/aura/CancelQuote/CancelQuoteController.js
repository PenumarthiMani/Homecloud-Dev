({
	doinit : function(component, event, helper) { 
        helper.ScenarioDetail(component,event);  
        helper.CancelTypes(component, event);
    },
    openModel: function(component, event, helper) {
      component.set("v.isOpen", true);
   },
   closeModel: function(component, event, helper) {
      component.set("v.isOpen", false);
   },
   CancelScenario: function(component, event, helper) {
      helper.CancelScenario(component,event); 
   }
    
})