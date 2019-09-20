({
doInit: function(component, event, helper) {
    var objectName=component.get("v.sObjectName");
    if(objectName=="Connection__c"){
        component.set("v.isModal",true);
    }else if(objectName=="Scenario__c"){
        component.set("v.isModal",false);
    }
    var pageRef = component.get("v.pageReference");
    console.log('pageRef**********',pageRef);
    var state = pageRef.state; // state holds any query params
    var base64Context = state.inContextOfRef;        
    if (base64Context.startsWith("1\.")) {
        base64Context = base64Context.substring(2);
    }
    var addressableContext = JSON.parse(window.atob(base64Context));
    component.set("v.recordId2", addressableContext.attributes.recordId);
    var recordVal = addressableContext.attributes.recordId;
    var action = component.get("c.connectionvalues");
    action.setParams({"Recordid":recordVal,"objectname":objectName});
     action.setCallback(this,function(a){
            var state = a.getState();
            if(state == "SUCCESS"){
                var result = a.getReturnValue();
                component.set("v.scenariodata",result);
            }
        }); $A.enqueueAction(action); 
        
    console.log(addressableContext+'recordId**********',recordVal);
    var errorMessage;
    
    if(objectName=="Connection__c" && recordVal == null){
        errorMessage="Please create Connection from Homebuyer record page";    
    }
    else if(objectName=="Scenario__c" && recordVal == null){
        errorMessage="Please create Scenario from Connection record page"; 
    }
    //Showing Error 
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": "Error!",
        "message": errorMessage,
        "duration":15000,
        "type":"error"
    });       
    toastEvent.fire(); 
    //Redirecting to Object Tab
    if(errorMessage != null && errorMessage != ''){
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": objectName
        });
        homeEvent.fire();
    }    
},
cancel:function(component,event,helper){  
    console.log('cancel');
    var recId= component.get('v.recordId2');
     console.log('recId'+recId);
    var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": recId
                        });
                        navEvt.fire();  
},
    handleSubmit:function(component,event,helper){
        
        var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": "Success!",
        "message": "Record has been created successfully.",
        "type": "success"
    });
    toastEvent.fire();
   var params = event.getParams();
    var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": params.response.id
        });
        navEvt.fire();
    },
    onSubmit:function(component,event,helper){
       event.preventDefault();
        var fields = event.getParam("fields");
        var firstName = component.find("myAtt").get("v.value");
       var lastName = component.find("myAtt1").get("v.value");
       var action = component.get("c.communityname");
        action.setParams({"communityid":firstName,"contactid":lastName});
        action.setCallback(this,function(a){
            
            var state = a.getState();
            if(state == "SUCCESS"){
                var result = a.getReturnValue(); 
                fields["Name"] = result;
               component.find("recordEditForm").submit(fields);
            }
        });         
        $A.enqueueAction(action);
    }
})