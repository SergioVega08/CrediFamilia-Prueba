public with sharing class OpportunityBigDealController {
    public OpportunityBigDealController() {

    }
    @AuraEnabled(cacheable=true)
    public List <Opportunity> getBigDeals(){

        List <Opportunity> bigDeal = [SELECT ID, NAME,Ammount
                                        FROM Opportunity 
                                        WHERE
                                        Status = 'Open - Won'
                                        AND Amount > 1000000
                                        ORDER BY Amount DESC]; 

        List <Contact> contacts = [SELECT ID, NAME, Email, Opportunity__c
                                    FROM Contact 
                                    WHERE Opportunity__c 
                                    IN :bigDeal];                   

        return bigDeal;                                
    }
}     