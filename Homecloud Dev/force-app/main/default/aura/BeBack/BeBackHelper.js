({
	beBack : function(component, event) {
        var useraction = component.get("c.createBeBack");
        useraction.setParams({"RecordId" : component.get("v.recordId")});
        useraction.setCallback(this, function(response){
            if(response.getState()==="SUCCESS" && component.isValid()){
                var respValue = response.getReturnValue();
                
                if(respValue == 'Success')
                {
                    this.showSuccessToast(component,event,'Beback has been created successfully');
                }
                else
                {
                    this.showErrorToast(component,event,respValue);
                }
                
            }
            $A.get('e.force:refreshView').fire();
            $A.get("e.force:closeQuickAction").fire();
        });
        $A.enqueueAction(useraction);	
    },
    showSuccessToast : function(component, event, Message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: Message,
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