/**
 * Retrieves the latest disaster preparedness products that are currently in stock.
 * This class is used to filter and fetch only those items which are both available and recently updated.
 */
public without sharing class LatestStockedDisasterItemsService {

    @InvocableMethod
    public static List<Response> getStockedDisasterItems() {

        // Retrieve Latest productIds that are in stock
        List<Inventory__c> inventoriesList = [SELECT 
                                                  Id
                                                , ProductId__c 
                                            FROM Inventory__c 
                                            WHERE Quantity__c > 0
                                              AND IsLatestProduct__c = true];

        // Generate a Set of product IDs from the retrieved stock
        Set<Id> productIdsSet = new Set<Id>();
        for(Inventory__c inv :  inventoriesList){
            productIdsSet.add(inv.ProductId__c);
        }
        
        // Retrieve products that are in stock
        List<PricebookEntry> peList = [SELECT 
                                          Id
                                        , Name
                                        , Product2Id
                                        , ProductCode
                                        , UnitPrice
                                        FROM PricebookEntry 
                                        WHERE Product2Id IN :productIdsSet];


        // Create products response
        List<Response> responses = new List<Response>();
        Response res = new Response();
        res.Prompt = JSON.serialize(peList);
        responses.add(res);
        return responses;
    }

    public class Response {
        @InvocableVariable
        public String Prompt;
    }

}