({
    doInit : function(component,event,helper){
        if(component.get("v.psobjname")=="Contact"){
            var pillTarget = component.find("lookup-pill");
            var pillTargetclose = component.find("lookup-pillclose");
            var lookUpTarget = component.find("lookupField");
            $A.util.removeClass(pillTarget, 'slds-hide');
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.addClass(pillTargetclose, 'slds-hide'); 
            helper.autopop(component,event,helper);
        }else if(component.get("v.psobjname")){            
        helper.loginuser(component,event);
        var cmpTarget = component.find('lookuplist');
         var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField");
          $A.util.removeClass(pillTarget, 'slds-hide');
        $A.util.addClass(pillTarget, 'slds-show');
        
        $A.util.removeClass(lookUpTarget, 'slds-show');
        $A.util.addClass(lookUpTarget, 'slds-hide');
        
        $A.util.removeClass(cmpTarget, 'slds-show');
        }
        /*     else if(component.get("v.psobjname")=="Lead"){
            var pillTarget = component.find("lookup-pill");
            var lookUpTarget = component.find("lookupField");
            $A.util.removeClass(pillTarget, 'slds-hide');
            $A.util.addClass(lookUpTarget, 'slds-hide'); 
            helper.autopop(component,event,helper);
        } */
    },    
    searchValues : function(component, event, helper) {
        helper.searchValuesHelper(component,event);
    },
    selectedValue : function(component, event, helper) {
        
        var objectId = event.currentTarget.id;
        var objectLabel = event.currentTarget.innerText;
        var sobjectFields = component.get('v.queryFields');
        var sobjectType = component.get('v.sobjectType');  
        var cmpTarget = component.find('lookuplist');
        var lookupValue = component.find('lookup');
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField");
        var updateEvent = component.getEvent("lookupEvent");
        updateEvent.setParams({
            "lookuprecordId" : objectId,
            "sobjectType" : sobjectType,
            "queryFields": sobjectFields,
        });
        updateEvent.fire();
        lookupValue.set('v.value', objectLabel);
        
        $A.util.removeClass(pillTarget, 'slds-hide');
        $A.util.addClass(pillTarget, 'slds-show');
        
        $A.util.removeClass(lookUpTarget, 'slds-show');
        $A.util.addClass(lookUpTarget, 'slds-hide');
        
        $A.util.removeClass(cmpTarget, 'slds-show');
    },
    
    clearSearch : function(component, event, helper) {
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField");
        
        var updateEvent = component.getEvent("lookupEvent");
        updateEvent.setParams({
            "lookuprecordId" : "",
            "sobjectType" : component.get("{!v.sobjectType}"),
            "queryFields": "",
        });
        updateEvent.fire();
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.searchValue",null);
        component.set("v.searchResults", null );
    },
    hideDiv : function(component, e){
        var lookupList = component.find('lookuplist');
        
        var lookupTimeout = setTimeout(function(){
            component.set("v.enableLookup",false);
        },500)
        },
    clearSearch1 : function(component, event, helper) {
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField");
        
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.searchValue",null);
        component.set("v.searchResults", null );
    }
})