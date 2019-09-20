({
    loadAllComponents: function (component, event, helper) {
        var id = component.get("v.recordId");
        var actiongetCommunityid = component.get("c.getCommunity");
        actiongetCommunityid.setParams({
            "QuoteId": id
        });
        actiongetCommunityid.setCallback(this, function (a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                component.set("v.quote", a.getReturnValue());
                if (component.get("v.quote.Cancelled__c") == true) {
                    component.set("v.Custommessage", "Lot transfer is not supported for Cancelled Scenario.");
                    document.getElementById("errordiv").style.display = "block";
                }
            }
        });
        $A.enqueueAction(actiongetCommunityid);
    },

    CancelTypes: function (component, event) {
        var id = component.get("v.recordId");
        var useraction = component.get("c.getCancelTo");
        useraction.setParams({
            "QuoteId": id
        });
        useraction.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS" && component.isValid()) {
                component.set("v.Cancel", response.getReturnValue());
            }
        });
        $A.enqueueAction(useraction);
    },

    SaveScenario: function (component, event) {
        var quoteid = component.get("v.recordId");
        var productId = component.get("v.ProductID");
        $A.util.removeClass(component.find("spinnerId"), 'slds-hide');
        if (productId != null && productId != '') {
            var actionsetlot = component.get("c.lotTransfer");
            actionsetlot.setParams({
                "QuoteId": quoteid,
                "NewLotId": productId
            });
            actionsetlot.setCallback(this, function (a) {
                $A.util.addClass(component.find("spinnerId"), 'slds-hide');
                var state = a.getState();
                if (state === "SUCCESS") {
                    component.set("v.Custommessage", a.getReturnValue());
                    if (a.getReturnValue().split(",")[0] != 'updated successfully') {
                        document.getElementById("errordiv").style.display = "block";
                    }
                    else {
                        var newscid = a.getReturnValue().split(",")[1];
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": newscid
                        });
                        navEvt.fire();
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "title": "Success",
                            "type": "success",
                            "message": "Lot has been transferred successfully."
                        });
                        resultsToast.fire();
                        component.set("v.Spinner", false);
                        component.set("v.isOpen", false);
                        //$A.get('e.force:refreshView').fire();                        
                        //component.set("v.isOpen", false);
                    }
                }
            });
            $A.enqueueAction(actionsetlot);
        }
        else {
            component.set("v.Custommessage", "Please select a Product");
            document.getElementById("errordiv").style.display = "block";
        }
    },
    CancelOldScenario: function (component, event) {
        var useraction = component.get("c.cancelScenario");
        useraction.setParams({ "scenarioDetails": component.get("v.quote") });
        useraction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultVal = response.getReturnValue();

                var resultId = resultVal.includes("Success") ? resultVal.split('-')[1] : '';
                if (resultVal.includes("Success")) {
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Success",
                        "type": "success",
                        "message": "Sucessfully cancelled previous Scenario."
                    });
                    resultsToast.fire();
                }
                else {
                    this.showErrorToast(component, event, "Something went wrong");
                }

            }
        });
        $A.enqueueAction(useraction);
    },
})