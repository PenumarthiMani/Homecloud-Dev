({
    quoteDetail : function(component, event) {
        var useraction = component.get("c.specQuotes");
        useraction.setParams({"CommunityId" : component.get("v.SelectedCommunity"),
                              "DivisionId" : component.get("v.SelectedDivision"),
                              "Status" : component.get("v.SelectedStatus")
                             });
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var resultVal = response.getReturnValue();
                component.set("v.SpecQuotes", resultVal);               
                /*if(resultVal == ''){
                     var Mes='No Spec Quotes Available';
                     this.showErrorToast(component,event,Mes);
                }*/
            }
            
        });
        $A.enqueueAction(useraction);    
    },
    DivisionValues : function(component, event) {
        var useraction = component.get("c.getDivisions");
        useraction.setCallback(this, function(response){
            if(response.getState()==="SUCCESS" && component.isValid()){
                component.set("v.Division",response.getReturnValue());
        }
        });
        $A.enqueueAction(useraction);	
    },
    CommunityValues : function(component, event) {
        component.set("v.SelectedCommunity","");
        var useraction = component.get("c.getCommunities");
        useraction.setParams({"DivisionId" : component.get("v.SelectedDivision")});
        useraction.setCallback(this, function(response){
            if(response.getState()==="SUCCESS" && component.isValid()){
                component.set("v.Communities",response.getReturnValue());
            }
        });
        $A.enqueueAction(useraction);	
    },
    InsertSpec : function(component, event) {
        var useraction = component.get("c.newSpecQuote");
        useraction.setParams({"CommunityId" : component.get("v.CommunityId"),
                              "DivisionId" : component.get("v.DivisionId")
                             });
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var resultVal = response.getReturnValue();
                this.quoteDetail(component,event);
                component.set("v.isOpen", false);
                this.showSuccessToast(component,event);
                var sObjectEvent = $A.get("e.force:navigateToSObject");
                sObjectEvent.setParams({
                    "recordId": resultVal.Id
                });
                sObjectEvent.fire();
                
            }
            else if(state === "ERROR")
            {
                this.showErrorToast(component,event,response.getError()[0].message);
            }
        });
        $A.enqueueAction(useraction);    
    },
    showSuccessToast : function(component, event) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: 'Spec Scenario has been created successfully!',
            duration:'500',
            type: 'success',
        });
        toastEvent.fire();
    },
    showErrorToast : function(component, event, Message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "type": "error",
            "message": Message
        });
        toastEvent.fire();
    }
})