({
    // this function is called on component load
    doinit : function(component, event, helper) { 
        // this function is called to get the signature types
        //helper.SignatureType(component,event);
        helper.ValidationsCheck(component,event);
    },
    // this function is called to check validation for wet signature
    /*validations : function(component, event, helper) { 
        helper.ValidationsCheck(component,event);
    },
    */
    // this function is called after file has uploaded
    handleUploadFinished : function(component, event, helper) {
        helper.UploadFinished(component,event);    
    },
    // this function automatic call by aura:waiting event  
   showSpinner: function(component, event, helper) {
       component.set("v.Spinner", true); 
   },
   // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    },
    openModel: function(component, event, helper) {
      component.set("v.isOpen", true);
      helper.ValidationsCheck(component,event);  
   },
   closeModel: function(component, event, helper) {
      component.set("v.isOpen", false);
      component.set("v.ErrorMessage","");
      component.set("v.HasError","false");
   },
    // this function is to close the quick action
    Cancel : function(component,event,helper){
     	$A.get("e.force:closeQuickAction").fire();
        component.set("v.isOpen", false);
    } 
})