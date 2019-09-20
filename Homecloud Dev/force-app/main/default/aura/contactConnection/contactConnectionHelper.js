({
    getlookupids : function(component, event, helper){
        var objecttype = event.getParam("sobjectType");
        if(objecttype == 'Division__c'){
            var divisionlookup = event.getParam("lookuprecordId");
            var divisionidval = component.get('v.divId');
            component.set("v.divId", divisionlookup);
        } else if(objecttype == 'Contact'){
            var contactlookup = event.getParam("lookuprecordId");            
            var contactidval=component.get('v.conId');
            component.set("v.conId", contactlookup);    
        } else if(objecttype == 'Community__c'){
            var communitylookup = event.getParam("lookuprecordId");            
            var communityidval=component.get('v.comId');
            component.set("v.comId", communitylookup);    
        } 
    },
    saveRecs: function(component, event, helper) {
        var divisionid = component.get("v.divId");
        var communityid=component.get("v.comId");
        var contactid=component.get("v.recordId");
        var dateclose=component.find("datefield").get("v.value");
        if(divisionid != '' && communityid != '' && contactid != '' && dateclose != null){
            var action=component.get("c.createConnection");
            action.setParams({"homebuyer":contactid,"div":divisionid,"communityid":communityid,"closingdate":component.get("v.estDate")});
            action.setCallback(this,function(response){
                var state=response.getState();
                if(state==="SUCCESS"){
                    var returnedval=response.getReturnValue();
                    if(returnedval != 'Error'){
                        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
                        dismissActionPanel.fire();                     
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": returnedval
                        });
                        navEvt.fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type": 'success',
                            "message": "Connection has been created successfully."
                        });
                        toastEvent.fire();
                    }
                    else{
                        var toastEventmesg = $A.get("e.force:showToast");
                        toastEventmesg.setParams({
                            "title": "Error!",
                            "type": 'Error',
                            "message": "Date Should be greater than today's Date"
                        });
                        toastEventmesg.fire();
                    }
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
                    dismissActionPanel.fire();               
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": 'error',
                        "message": "Something went wrong."
                    });
                    toastEvent.fire();                                          
                }
            }); 
            $A.enqueueAction(action);
        }       
        else{   
            if(communityid ==''){
                component.set("v.customError",'Please fill required fields.');
                component.set("v.isError",true);
            }
            if(divisionid ==''){ 
                component.set("v.customError",'Please fill required fields.');
                component.set("v.isError",true);
            }
            if(contactid ==''){
                component.set("v.customError",'Please fill required fields.');
                component.set("v.isError",true);
            }  
            if(dateclose == null){
                component.set("v.customError",'Please fill required fields.');
                component.set("v.isError",true);
            }  
        }
    },
})