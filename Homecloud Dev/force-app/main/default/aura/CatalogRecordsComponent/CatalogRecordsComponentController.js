({
    //initilizing the component
    initilize : function(component,event,helper) {
        console.log('Recordtype:'+component.get('v.recordtype'));
        console.log('recordId:'+component.get('v.recordId'));
        component.set('v.displayspinner',true);
      //  helper.diu(component,event,helper);
        helper.doinitpermissionforprofile(component,event,helper);
    },
    //fires only when selecting the row for action or for View button
    onrowsel : function(component,event,helper){
        component.set('v.displayspinner',true);
        var action = event.getParam('action'); console.log('action:'+JSON.stringify(action));
        var row = event.getParam('row');console.log('row:'+JSON.stringify(row));
        switch (action.name) {
            case 'Edit': 
                helper.handleedit(component,event,helper,row);
                break;
            case 'Delete':
                helper.handledelete(component,event,helper,row);
                break;
            case 'view_details':
            //    alert('rowdetails:'+row.Name+'  Price__c:'+row.Price__c+' id:'+row.Id);
                helper.Viewbuttonaction(component,event,helper,row);
                break;
        }
        component.set('v.displayspinner',false);
    },
   //onclick of button creating a records, holded for review
    createnewrec : function(component,event,helper){
        alert('comp:'+ component.get('v.recordtypeId')+' recordtype:'+ component.get('v.recordtype'));
       var rectypeid=component.get('v.recordtypeId');
        alert('c'+rectypeid);
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Catalog__c",
            "recordTypeId" : rectypeid
        });
        createRecordEvent.fire();
    },
    onchangesearchval:function(component,event,helper){
     //   debugger;
        component.set('v.displayspinner',true);
        var searchval=event.getSource().get("v.value");
        console.log('searchval:'+JSON.stringify(searchval)); 
      //  alert('searchval:'+searchval);
          component.set('v.Searchstringval',searchval);
      //  alert('cc:'+component.get('v.Searchstringval'));
        component.set('v.offsetcount',0);
        var act=component.get('c.dosearchval');
        act.setParams({
             'Communityid' : component.get("v.recordId"),
            'recordtype' : component.get("v.recordtype"),
            'sortopt' : component.get("v.sortopt"),
            'sortfield' : component.get("v.sortfield"),
            'offsetcount' : component.get("v.offsetcount"),
            'limitcount' : component.get("v.limitcount"),
            'searchstring' : searchval
        });
        act.setCallback(this,function(res){
            var state=res.getState();
            console.log('state:'+state);
            if(state==='SUCCESS'){
                var retval=res.getReturnValue();
                
                component.set('v.TotalSearchcountofrecords',retval.TotalSearchcountofrecords);
                component.set('v.catalogrecs',retval.recordlist);
                component.set('v.Searchcountofrecords',retval.countofsearchedrecords);
            //    alert('response:'+JSON.stringify(retval));
              //  component.set('v.Searchstringval',retval.searchstringdata);
                //  alert('retval.searchstring:'+string.valueof(retval.searchstringdata));
                //  alert('retval.searchstring:'+(retval.searchstringdata));
                component.set('v.offsetcount',retval.offsetcount);
            //     alert('Searchcountofrecords :'+retval.countofsearchedrecords);
                // alert('retval.TotalSearchcountofrecords:'+retval.TotalSearchcountofrecords);
         		helper.validateactionstodisplay(component,event,helper);
              /*  if(retval.offsetcount==0){
                    component.set('v.hasprevious',false);
                }
                else
                    component.set('v.hasprevious',true);
                if(retval.TotalSearchcountofrecords==retval.countofsearchedrecords){
                     component.set('v.hasnext',false);
                }
                else
                     component.set('v.hasnext',true);
                     
                     */
              /*  console.log('retval:'+retval);
                console.log('response:'+retval);
                console.log('Searchcountofrecords :'+retval.countofsearchedrecords);
                 console.log('retval.TotalSearchcountofrecords:'+retval.TotalSearchcountofrecords);
              //  console.log('recordtypeid:'+retval.recordtypeid);
             //   console.log('recordlist:'+JSON.stringify(retval.recordlist));
               console.log('Searchstringval:'+component.get('v.Searchstringval'));
               */
            }
        });
        $A.enqueueAction(act);
        component.set('v.displayspinner',false);
    },
    sortdirection: function(component,event){
        console.log('sortdirection');
         var fieldName = event.getParam('fieldName');
            var sortDirection = event.getParam('sortDirection');
        console.log('fieldName:'+fieldName);
        console.log('sortDirection:'+sortDirection);
        var searchst=component.get('v.Searchstringval');
        console.log('searchst:'+searchst);
        component.set('v.offsetcount',0);
        component.set('v.sortfield',fieldName);
     //   component.set('v.sortopt',sortDirection);
        var act=component.get('c.dosort');
        act.setParams({
            'Communityid' : component.get("v.recordId"),
            'recordtype' : component.get("v.recordtype"),
            'sortopt' : component.get("v.sortopt"),
            'sortfield' : component.get("v.sortfield"),
            'offsetcount' : component.get("v.offsetcount"),
            'limitcount' : component.get("v.limitcount"),
            'searchstring' : component.get("v.Searchstringval")
        });
        act.setCallback(this,function(res){
            var state=res.getState();
            if(state==='SUCCESS'){
                 var retval=res.getReturnValue();
                component.set('v.catalogrecs',retval.recordlist);
                component.set('v.offsetcount',retval.offsetcount);
                component.set('v.sortopt',retval.sortopt);
                component.set('v.Searchcountofrecords',retval.countofsearchedrecords);
                component.set('v.TotalSearchcountofrecords',retval.TotalSearchcountofrecords);
                console.log('sort ret:'+retval.sortopt);
                component.set('v.hasprevious',false);
                component.set('v.hasnext',true);
                console.log('retval.recordlist:'+retval.recordlist);
                console.log('retval.offsetcount:'+retval.offsetcount);
                helper.validateactionstodisplay(component,event,helper);
            }
        });
        $A.enqueueAction(act);
    },
    clicknext: function(component,event,helper){
       // alert('hi Next');
        helper.Paginationactions(component,event,helper,'Next');
    },
    clickprevious : function(component,event,helper){
        //alert('hi Previous');
        helper.Paginationactions(component,event,helper,'Previous');
    }
})