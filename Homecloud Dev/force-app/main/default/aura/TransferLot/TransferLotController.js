({
    doinit: function (component, event, helper) {
        helper.CancelTypes(component, event);
    },
    //To update the Quote
    upsertQuote: function (component, event, helper) {
        component.set("v.Spinner", true);
        helper.CancelOldScenario(component, event);
        helper.SaveScenario(component, event);        
    },

    lookupEvent: function (component, event) {
        var LotId = event.getParam("lookuprecordId");
        component.set("v.ProductID", LotId);
    },
    openModel: function (component, event, helper) {
        helper.loadAllComponents(component, event, helper);
        component.set("v.isOpen", true);
    },
    closeModel: function (component, event, helper) {
        component.set("v.isOpen", false);
    },

    hideerror: function (component, event, helper) {
        document.getElementById("errordiv").style.display = "none";
    }
})