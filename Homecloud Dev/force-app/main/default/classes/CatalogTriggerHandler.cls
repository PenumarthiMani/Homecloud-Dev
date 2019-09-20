public class CatalogTriggerHandler {
	public static void deleteCatalog(Map<Id,Catalog__c> oldCatalogs){
        List<Catalog__c> delCatalogs=[Select Id,Name,(Select Id,Name from Option__r) from Catalog__c where Id IN:oldCatalogs.keySet()];
        for(Catalog__c dc:delCatalogs){
            if(!dc.Option__r.isEmpty()){
             oldCatalogs.get(dc.Id).addError('You cannot delete Catalog with Options.');   
            }            
        }
    }	
}