({
    //pulling the records from the database.
    initrecords: function(component,event,helper){
        var act=component.get('c.doinitialize');
        act.setParams({
            'Communityid' : component.get("v.recordId"),
            'recordtype' : component.get("v.recordtype"),
            'sortopt' : component.get("v.sortopt"),
            'sortfield' : component.get("v.sortfield"),
            'offsetcount' : component.get("v.offsetcount"),
            'limitcount' : component.get("v.limitcount")
        });
        act.setCallback(this,function(res){
            var state=res.getState();
            if(state==='SUCCESS'){
                var retval=res.getReturnValue();
                //component.set('v.catalogrecs',res.getReturnValue());
                console.log('response:'+retval);
                console.log('countofrecords:'+retval.countofrecords);
                console.log('recordtypeid:'+retval.recordtypeid);
                console.log('recordlist:'+JSON.stringify(retval.recordlist));
                component.set('v.catalogrecs',retval.recordlist);
                component.set('v.recordtypeId',retval.recordtypeid);
                component.set('v.countofrecords',retval.countofrecords);
                component.set('v.Searchcountofrecords',retval.countofsearchedrecords);
                component.set('v.offsetcount',retval.offsetcount);
                 component.set('v.displayspinner',false);
                component.set('v.TotalSearchcountofrecords',retval.TotalSearchcountofrecords);
                console.log('retval.TotalSearchcountofrecords:'+retval.TotalSearchcountofrecords);
                helper.validateactionstodisplay(component,event,helper);
            }
        });
        $A.enqueueAction(act);
        
    },
    //popup for success or error messages
    notifymessages: function(component,state,message,variant){
        component.find('notifLib').showToast({
            "title": state,
            "variant":variant,
            "message": message
        });
    },
    //checking for the permission of object based on teh record type
    doinitpermissionforprofile: function(component,event,helper){
        var act=component.get('c.docheckpermissionforprofile');
        act.setParams({
            'objectname' : 'catalog__c'
        });
        act.setCallback(this,function(res){
            var state=res.getState();
            if(state==='SUCCESS'){
                // component.set('v.catalogrecs',res.getReturnValue());
                console.log('response:'+res.getReturnValue());
                console.log('response:'+JSON.stringify(res.getReturnValue()));
                var retval=res.getReturnValue();
                console.log('******'+JSON.stringify(retval));
                component.set('v.iseditable',retval.isEditable);
                component.set('v.isdeleteable',retval.isDelete);
                if(retval.isEditable || retval.isDelete || retval.isReadable || retval.iscreate){
                    //alert();
                    helper.diu(component,event,helper);
                    helper.initrecords(component,event,helper);
                    component.set('v.hasobjectpermission',true);
                }
                else{
                    component.set('v.hasobjectpermission',false);
                }
                /*for ( var key in retval ) {
                     component.set('v.iseditable',key);
                     component.set('v.isdeleteable',retval[key]);
                     console.log('iseditable'+component.get('v.iseditable'));
                     console.log('isdeleteable'+component.get('v.isdeleteable'));
                 }*/
            }
        });
        $A.enqueueAction(act);  
    },
    handleedit : function(component,event,helper,row){
        var eve=event.getSource().get("v.value"); console.log('eve:'+eve);
        //  alert(eve);
        //window.open('/'+eve,'_blank');
        window.open('/'+row.Id,'_blank');
    },
    handledelete : function(component,event,helper,row){
        var eve=event.getSource().get("v.value");
        console.log('delete rec:'+eve);
        // alert(eve);
        // window.open('/'+eve,'_blank');
        var act=component.get('c.dodelete');
        act.setParams({
            'Communityid' : component.get("v.recordId"),
            'recordtype' : component.get("v.recordtype"),
            'delrecid': row.Id
            //  'delrecid' : event.getSource().get("v.value")
        });
        act.setCallback(this,function(res){
            var state=res.getState();
            if(state==='SUCCESS'){
                var retval=res.getReturnValue();
                console.log('response:'+retval);
                console.log('response:'+retval.countofrecords);
                console.log('response:'+retval.recordlist);
                component.set('v.catalogrecs',retval.recordlist);
                component.set('v.countofrecords',retval.countofrecords);
                //  component.set('v.catalogrecs',res.getReturnValue());
                $A.get('e.force:refreshView').fire();
                component.find('notifLib').showToast({ 
                    "title": 'Success',
                    "variant":"info",
                    "message": 'You have Successfully Deleted the Record'
                });
                
            }
        });
        $A.enqueueAction(act);
    },
    //calling this method from the init controller and initalizing the columns
    diu: function(component,event,helper){
        var actions = [
            { label: 'Edit', name: 'Edit' },
            { label: 'Delete', name: 'Delete' }
        ]
        component.set('v.columns', [
            { label: 'Name', fieldName: 'Name', type: 'text', sortable: true },
            { label: 'CatalogCode', fieldName: 'CatalogCode__c', type: 'text' },
            { label: 'Active', fieldName: 'IsActive__c', type: 'boolean' },
            { label: 'Price', fieldName: 'Price__c', type: 'currency' , sortable: true},
            {label: 'View', type: 'button', initialWidth: 135, typeAttributes: { label: 'View Details', name: 'view_details', title: 'Click to View Details'}},
            { type: 'action', typeAttributes: { rowActions: actions } }
        ]);
    },
    Viewbuttonaction: function(component,event,helper,row){
       // alert('Viewbuttonaction method:'+row.Name);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": row.Id,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    Paginationactions : function(component,event,helper,eventaction){
        component.set('v.displayspinner',true);
        console.log('searchstring:'+component.get('v.Searchstringval'));
        var countofrecords=component.get('v.countofrecords');
        console.log('eventaction:'+eventaction);
        console.log('sort:'+component.get('v.sortopt'));
        var act= component.get('c.doactions');
        act.setParams({
            'Communityid' : component.get("v.recordId"),
            'recordtype' : component.get("v.recordtype"),
            'sortopt' : component.get("v.sortopt"),
            'sortfield' : component.get("v.sortfield"),
            'offsetcount' : component.get("v.offsetcount"),
            'limitcount' : component.get("v.limitcount"),
            'searchstring' : component.get('v.Searchstringval'),
            'whichaction' : eventaction
        });
        act.setCallback(this,function(res){
            var state=res.getState();
            if(state==='SUCCESS'){
                var retval=res.getReturnValue();
                component.set('v.catalogrecs',retval.recordlist);
                component.set('v.offsetcount',retval.offsetcount);
                component.set('v.Searchcountofrecords',retval.countofsearchedrecords);
                console.log('retval.recordlist:'+retval.recordlist);
                console.log('retval.offsetcount:'+retval.offsetcount);
                console.log('countofsearchedrecords:'+retval.countofsearchedrecords);
                helper.validateactionstodisplay(component,event,helper);
            }
        });
        $A.enqueueAction(act);
        component.set('v.displayspinner',false);
    },
    validateactionstodisplay:function(component,event,helper){
        console.log('validateactionstodisplay');
        var countofrecords=component.get('v.countofrecords');
        var Searchcountofrecords=component.get('v.Searchcountofrecords');
        var TotalSearchcountofrecords=component.get('v.TotalSearchcountofrecords');
        var offsetcount=component.get('v.offsetcount');
         var limitcount=component.get('v.limitcount');
        console.log('countofrecords:'+countofrecords);
        console.log('Searchcountofrecords:'+Searchcountofrecords);
        console.log('TotalSearchcountofrecords:'+TotalSearchcountofrecords);
        console.log('offsetcount:'+offsetcount);
         console.log('limitcount:'+limitcount);
        if(offsetcount==0 ){
            component.set('v.hasprevious',false);
        }
        else{
             component.set('v.hasprevious',true);
        }
        var previous=component.get('v.hasprevious');
        console.log('previous:'+previous);
        if(TotalSearchcountofrecords==Searchcountofrecords ){
            component.set('v.hasnext',false);
        }
        else{
             component.set('v.hasnext',true);
        }
        
    }
    
    
})