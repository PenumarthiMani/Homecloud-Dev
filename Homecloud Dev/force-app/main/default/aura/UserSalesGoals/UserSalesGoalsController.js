({
    init : function (component, event, helper){
       var userRec = event.getParam("UserId");
        component.set("v.turboGoolDisplay", true);
        component.set("v.editandSaveDisplay", true);
        var d = new Date();
        var yearSel = d.getFullYear();
        component.set("v.yearChangedefault",yearSel);
        component.set("v.yearChangedefault123",yearSel.toString());
        var year  = component.get("c.currentyear");
        year.setCallback(this, function(response){
            var state = response.getState();
            if(state==='SUCCESS')
            {
                var y = response.getReturnValue();
                component.set("v.yearChange", y);
                helper.userYearChange(component, event,  userRec, yearSel);
                }
            
        });
       $A.enqueueAction(year);
        		
    },
    
    /** User Change Function **/ 
    handleComponetEvent : function (component, event, helper){
        var userRec = event.getParam("lookuprecordId");
        component.set("v.userId" , userRec);
        var yearSel = component.get("v.yearChange");
        component.set("v.norecord",true);
        component.set("v.turboGoolDisplay",true);
        component.set("v.editandSaveDisplay", true);
        component.set("v.editvariable", true);
        if(yearSel != null && yearSel != '' && userRec != null && userRec != ''){
            component.set("v.spinner", true);
            var yearSel  = component.find('select').get('v.value');
            helper.userYearChange(component, event,  userRec, yearSel);
        }
        else if(userRec == null || userRec == ''){
            component.set("v.norecord",false);
            component.set("v.turboGoalList",false);
            component.set("v.turboGoolDisplay",false);
        }
    },
    
    handleDefaultUserComponetEvent : function(component, event, helper){
        var userRec = event.getParam("UserId"); 
        component.set("v.userId" , userRec);
        var yearSel = component.get("v.yearChange");
        component.set("v.editvariable", true);
        if(yearSel != null && yearSel != '' && userRec != null && userRec != ''){
            component.set("v.spinner", true);
            helper.userYearChange(component, event,  userRec, yearSel);
        }
    },
    
    /**Year Function **/
    yearChange : function(component, event, helper){
        component.set("v.yearbool",false);
        var year  = component.find('select').get('v.value');
        //component.set("v.yearChange", year);
        var us = component.get("v.userId");
        component.set("v.turboGoolDisplay", true);
        component.set("v.editandSaveDisplay", true);
        component.set("v.editvariable", true);
        if(us != null && us != '' && year != null && year != ''){
            component.set("v.spinner", true);
            helper.userYearChange(component, event,  us, year);
        }
        else if(year == '' || us == ''){
            component.set("v.turboGoalList",false);
            component.set("v.turboGoolDisplay",false); 
        }  
    },
    /** Edit ***/
    editAction :function(component, event, helper){
        component.set("v.editvariable", false);
        component.set("v.editandSaveDisplay", false);
    },
    /** Save ***/
    saveAction :function(component, event, helper){
        
        var turbList = component.get("v.turboGoalList");       
        for (var i = 0; i < turbList.length; i++) {
            if(turbList[i].Goal__c < 0){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Negetive goal",
                    "message": "goals cannot be negetive.",
                    "type" : "Error"
                });
                toastEvent.fire();
                component.set("v.editvariable", false);
                component.set("v.editandSaveDisplay", false);
                
                component.set("v.negMessage", true);
                
               
                break;
            }
            else{
                component.set("v.negMessage", false);
            }
            
        }
        
        var valMes = component.get("v.negMessage"); 
        if(valMes == false){
            component.set("v.editandSaveDisplay", true);
            component.set("v.editvariable", true);
            component.set("v.spinner", true);
            helper.saveMethod(component,event,turbList);
        }
    },
    /** Cancel ***/
    cancelAction :function(component, event, helper){
        
        component.set("v.editandSaveDisplay", true);
        component.set("v.editvariable", true);
        
        var year  = component.find('select').get('v.value');
        component.set("v.yearChange", year);
        var us = component.get("v.userId");
        if(us != null && us != '' && year != null && year != ''){
            component.set("v.spinner", true);
            helper.userYearChange(component, event,  us, year);
        }
        
    }
    
})