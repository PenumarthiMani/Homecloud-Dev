({
    init : function(cmp, event, helper) {
        var action = cmp.get("c.getListSettings"); 
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var respVal = response.getReturnValue();
                console.log('result::',respVal);
                var strname = [];
                for(var i=0;i<respVal.length;i++){
                    strname.push(respVal[i].RecordType__c);
                }
                window.location.href = strname;
            }
        });
        $A.enqueueAction(action);
    }
})