({
    /*// this function is called to get the signature types and to set them
    SignatureType : function(component, event) {
        var useraction = component.get("c.SignatureType");        
        useraction.setParams({"RecordId" : component.get("v.recordId")});
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var resultVal = response.getReturnValue();
                component.set("v.SignatureTypes",resultVal);
            }
        });
        $A.enqueueAction(useraction);
	},*/
    // this function is called to check the validation rules before allowing to upload wet signature attachment
    ValidationsCheck : function(component, event) {
        var useraction = component.get("c.WetSignaturevalidations");        
        useraction.setParams({"QuoteId" : component.get("v.recordId")
                              //"SelectedType" : component.get("v.SelectedType") 
                             });
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var resultVal = response.getReturnValue();
                if(resultVal == 'Success')
                {
                    component.set("v.ValidationsPassed","true");
                    component.set("v.HasError","false");
                }
                else
                {
                    component.set("v.ErrorMessage",resultVal);
                    component.set("v.HasError","true");
                }    
            }
            else
            {
                component.set("v.ErrorMessage",response.getError()[0].message);
                component.set("v.HasError","true");
                
            }    
        });
        $A.enqueueAction(useraction);    
    },
    // this function to update the quote detials after attachment upload and to show success and error messages
    UploadFinished : function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        var fileName = uploadedFiles[0].name;
        var useraction = component.get("c.updateQuote");        
        useraction.setParams({"QuoteId" : component.get("v.recordId"),
                              "SelectedType" : component.get("v.SelectedType") 
                             });
        useraction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var resultVal = response.getReturnValue();
                if(resultVal == 'Success')
                {
                    this.showSuccessToast(component,event,"File "+fileName+" Uploaded successfully.");
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId"),                        
                    });
                    navEvt.fire();
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire(); 
                    
                }
                else
                {
                    this.showSuccessToast(component,event,"File "+fileName+" Uploaded successfully.");
                    this.showErrorToast(component,event,resultVal);
                    $A.get("e.force:closeQuickAction").fire();                                 
                }    
            }
            else
            {
                this.showSuccessToast(component,event,"File "+fileName+" Uploaded successfully."); 
                this.showErrorToast(component,event,response.getError()[0].message);
                $A.get("e.force:closeQuickAction").fire();                
            }  
            component.set("v.isOpen", false);
        });
        $A.enqueueAction(useraction);  
        
    },
    // this function is to show the error message
    showErrorToast : function(component, event, Message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "type": "error",
            "message": Message
        });
        toastEvent.fire();
    },
    // this function is to show the success message
    showSuccessToast : function(component, event, Message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": "success",
            "message": Message
        });
        toastEvent.fire();
    }
})