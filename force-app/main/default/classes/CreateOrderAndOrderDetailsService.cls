// Class called from Flow
// Flow name is Create an order with the customer ID and order details
public without sharing class CreateOrderAndOrderDetailsService {

    @InvocableMethod
    public static List<Response> createOrderAndOrderDetails(List<Request> requests) {

        Request input = requests[0];

        // create Order__c
        Order__c order = new Order__c(AccountId__c = input.accountId
                                        , Orderer__c = input.contactId
                                        , OrderDate__c = Date.today()
                                        , IsSelfOrder__c = true);
        insert order;

        System.debug('JSON.deserializeUntyped(input.orderDetails) = ' + JSON.deserializeUntyped(input.orderDetails));

        List<Object> orderInfoObjList = (List<Object>)JSON.deserializeUntyped(input.orderDetails);

        // create OrderDetails__c
        List<OrderDetail__c> orderDtlList = new List<OrderDetail__c>();
        for(Object odObj : orderInfoObjList){
            Map<String, Object> odMap = (Map<String, Object>)odObj;
            orderDtlList.add(new OrderDetail__c(OrderId__c = order.Id 
                                                , ProductId__c = String.valueOf(odMap.get('ProductId__c'))
                                                , Quantity__c = Integer.valueOf(odMap.get('Quantity__c'))));
        }
        insert orderDtlList;

        // Create products response
        List<Response> responses = new List<Response>();
        Response res = new Response();
        res.isSuccess = true;
        res.orderRow = [SELECT Id, Name FROM Order__c WHERE Id = :order.Id];
        responses.add(res);
        return responses;
    }

    public class Request {
        @InvocableVariable(required=true)
        public Id accountId;

        @InvocableVariable(required=true)
        public Id contactId;

        @InvocableVariable(required=true)
        public String orderDetails;
    }

    public class Response {
        @InvocableVariable
        public Boolean isSuccess;
        
        @InvocableVariable
        public Order__c orderRow;
    }
}