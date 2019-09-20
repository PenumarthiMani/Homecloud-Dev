trigger CatalogTrigger on Catalog__c (before delete) {
	if(Trigger.isDelete && Trigger.isBefore){
        CatalogTriggerHandler.deleteCatalog(Trigger.oldMap);
    }
}