({
    callServer : function(component,method,params,callback){
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                // pass returned value to callback function
                callback.call(this,response.getReturnValue());   
            } else if (state === "ERROR") {
                // generic error handler
                var errors = response.getError();              
            }
        });
        $A.enqueueAction(action);
    },
    
    searchValuesHelper : function(component,event) {
        var sObjectName = component.get("v.sobjectType");
        var sObjectFields = component.get("v.queryFields");
        var objectFilter1 = component.get("v.searchFilter1");
        var objectFilter2 = component.get("v.searchFilter2");
        var objectFilter3 = component.get("v.searchFilter3");
        var filter1 = component.get("v.filter1");
        var filter1value = component.get("v.filter1value");
        var filter2 = component.get("v.filter2");
        var filter2value = component.get("v.filter2value");
        var filter3 = component.get("v.filter3");
        var filter3value = component.get("v.filter3value");
        var searchValue = component.get("v.searchValue");
        component.set("v.enableLookup",true);
        var cmpTarget = component.find('lookuplist');
        var params = {"sObjectName" : sObjectName,"sObjectFields" : sObjectFields,"objectFilter1" : objectFilter1,"objectFilter2" : objectFilter2,"objectFilter3" : objectFilter3,"filter1" : filter1,"filter1value" : filter1value,"filter2" : filter2,"filter2value" : filter2value,"filter3" : filter3,"filter3value" : filter3value,"searchValue" : searchValue};
        $A.util.removeClass(cmpTarget, 'slds-hide');
        $A.util.addClass(cmpTarget, 'slds-show');
        this.callServer(component,"c.getSearchResults",params,function(response){
            if(!$A.util.isEmpty(response)){
                component.set("v.searchResults",response);
            }
        });
    },
    autopop : function(component,event,helper){
        var record_id=component.get("v.precordId");
        var Sobjname=component.get("v.psobjname");
        if(Sobjname==='Contact'){
            var action=component.get("c.getCons");           
            action.setParams({"conid":record_id});
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){
                    var result = response.getReturnValue();
                    component.set("v.searchValue",result.Name);
                    var cmpEvent = component.getEvent("lookupEvent");
                    cmpEvent.setParams({ "queryFields" :'Id,Name', "sobjectType" :Sobjname,"lookuprecordId":result.Id});
                    cmpEvent.fire();                      
                }
                else if (state === "ERROR") {
                    // generic error handler
                    var errors = response.getError();              
                }
            });
            $A.enqueueAction(action);
        }
    },
     loginuser : function(component,event)
    {
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state === 'SUCCESS'){
                var username = response.getReturnValue();
                console.log('username'+ JSON.stringify(username));
                component.set("v.searchValue",username.Name);   
                var cmpEvent = component.getEvent("defaultuser");
                cmpEvent.setParams({ "UserRecord" : username.Name , "UserId" : username.Id});
                cmpEvent.fire();  
              
               // this.searchValuesHelper(component,event);
            }     
        });
        $A.enqueueAction(action);  
    }
    /*  autopop : function(component,event,helper){
        var record_id=component.get("v.precordId");
        var Sobjname=component.get("v.psobjname");
        if(Sobjname==='Contact'){
            var action=component.get("c.getAccLeads");           
            action.setParams({"accid":record_id,"leadid":''});
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){
                    var result = response.getReturnValue();
                    component.set("v.searchValue",result.Name);
                    var cmpEvent = component.getEvent("lookupEvent");
                    cmpEvent.setParams({ "queryFields" :'Id,Name', "sobjectType" :Sobjname,"lookuprecordId":result.Id});
                    cmpEvent.fire();                      
                }
                else if (state === "ERROR") {
                // generic error handler
                var errors = response.getError();
                console.log("errors" + errors);                
                console.log("errors" + errors[0].message);                
            }
            });
            $A.enqueueAction(action);
        }
        else if(Sobjname==='Lead'){
            var action=component.get("c.getAccLeads");           
            action.setParams({"accid":'',"leadid":record_id});
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){
                    var result = response.getReturnValue();
                    component.set("v.searchValue",result.Name);
                    var cmpEvent = component.getEvent("lookupEvent");
                    cmpEvent.setParams({ "queryFields" :'Id,Name', "sobjectType" :Sobjname,"lookuprecordId":result.Id});
                    cmpEvent.fire();                      
                }
                else if (state === "ERROR") {
                // generic error handler
                var errors = response.getError();
                console.log("errors" + errors);                
                console.log("errors" + errors[0].message);                
            }
            });
            $A.enqueueAction(action);            
        }
    } */
    
})