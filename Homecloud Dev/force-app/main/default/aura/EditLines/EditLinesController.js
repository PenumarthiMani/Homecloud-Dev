({
    doinit : function(component, event, helper) { 
        helper.quoteDetail(component,event);       
    },	
    openModel: function(component, event, helper) {
        component.set("v.isOpen", true);
    },
    closeModel: function(component, event, helper) {   
        component.set("v.isOpen", false);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),                        
        });
        navEvt.fire();
        window.setTimeout(
            $A.getCallback(function() {          
                $A.get("e.force:refreshView").fire();    
            }), 500
        );         
    }, 
    LotEdit: function(component, event, helper) {
        component.set("v.LotEdit", true);
    },
    ModelEdit: function(component, event, helper) {
        component.set("v.ModelEdit", true);
    },
    OptionEdit: function(component, event, helper) {
        var selectedopt = event.currentTarget.dataset.datavalue;
        component.set("v.OptionsEdit", true); 
        component.set("v.EditId",selectedopt); 
    }, 
    Cancel: function(component, event, helper) {
        component.set("v.LotEdit", false);
        component.set("v.ModelEdit", false);
        component.set("v.OptionsEdit", false); 
        component.set("v.PackageEdit", false);
    },
    SaveLot : function(component, event, helper) {
        helper.UpdateLot(component,event);
        component.set("v.LotEdit", false);
    },
    SaveModel : function(component, event, helper) {
        helper.UpdateModel(component,event);
        component.set("v.ModelEdit", false);
    },
    SaveOption : function(component, event, helper) {
        helper.UpdateOption(component,event);
        component.set("v.OptionsEdit", false);
    },
    GroupNames : function(component, event, helper) {
        helper.Groupvalues(component,event);
        helper.UnGroupedLines(component,event); 
        component.set("v.GroupingPopUp", true);
        component.set("v.AvailablePopUp", false);
    }, 
    GroupOption : function(component, event, helper) {
        helper.GroupOption(component,event);
        
    },
    RemoveFromGroup : function(component, event, helper) {
        helper.RemoveFromGroup(component,event);
    }, 
    TieGroups : function(component, event, helper) {
        helper.TieWithGroups(component,event);
    },
    TieGroupsAndClose : function(component, event, helper) {
        helper.TieWithGroups(component,event);
        helper.CancelSubPopUps(component,event); 
    }, 
    AvailableModels : function(component, event, helper) {
        component.set("v.AvailablePopUp", false);
        component.set("v.AddModelPopUp", true);
        component.set("v.Type",'Model'); 
        helper.SelectModel(component,event); 
    },
    AvailableLots : function(component, event, helper) {
        component.set("v.AvailablePopUp", false);
        component.set("v.AddModelPopUp", true);
        component.set("v.Type",'Lot');  
        helper.SelectLot(component,event);        
    },
    AvailableOptions : function(component, event, helper) {
        component.set("v.ProductName",''); 
        helper.InsertOptionProducts(component,event);
    },
    SearchOptions : function(component, event, helper) {
        helper.SelectOptions(component,event);
    },  
    AvailableCategories : function(component, event, helper) {
        helper.StatusValidation(component,event);         
    },
    CancelSubPopup : function(component, event, helper) {
        helper.CancelSubPopUps(component,event);  
    }, 
    InsertLotModelPackage : function(component, event, helper) {
        helper.InsertLotModelPackage(component,event);  
    },
    InsertOptions : function(component, event, helper) {
        
        helper.InsertOptionProducts(component,event); 
        helper.CancelSubPopUps(component,event);
        
    }, 
    handleSelected : function(component, event, helper) {
        helper.SelectionControl(component,event);       
    },
    DeleteLot : function(component, event, helper) {
        component.set("v.isOpenedLot", true);
        helper.DeletePopup(component,event);       
    },
    DeleteModel : function(component, event, helper) {
        component.set("v.isOpenedModel", true);
        helper.DeletePopup(component,event);        
    },
    DeleteYes : function(component, event, helper) {
        helper.DeleteProductYes(component,event);       
    },
    DeleteNo : function(component, event, helper) {
        helper.DeleteProductNo(component,event);       
    },   
    DeleteOption : function(component, event, helper) {
        helper.DeleteOption(component,event);       
    }, 
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", false); 
    },
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    } 
})