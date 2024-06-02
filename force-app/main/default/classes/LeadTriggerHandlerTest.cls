@isTest
private class LeadTriggerHandlerTest {

    @isTest
    static void testHandleTitleNormalization() {
        // Create test data (Leads)
        List<Lead> testLeads = new List<Lead>();
        // Add your test data here (e.g., create Leads with different titles)
        Lead lead1 = new Lead(Title = 'VP of Sales', LastName = 'Test1', Company = 'Test Company1');
        Lead lead2 = new Lead(Title = 'Sales Manager', LastName = 'Test2', Company = 'Test Company2');
        Lead lead5 = new Lead(Title = 'Business Owner', LastName = 'Test2', Company = 'Test Company5');
        Lead lead3 = new Lead(Title = 'Marketing', LastName = 'Test3' , Company = 'Test Company3');
        Lead lead4 = new Lead(Title = 'Manager - Marketing', LastName = 'Test4', Company = 'Test Company4');
        Lead lead6 = new Lead(Title = 'head', LastName = 'Test6', Company = 'Test Company6');
        Lead lead7 = new Lead(Title = 'jr', LastName = 'Test7', Company = 'Test Company7');
        
        testLeads.add(lead1);
        testLeads.add(lead2);
        testLeads.add(lead3);
        testLeads.add(lead4);
        testLeads.add(lead5);
        testLeads.add(lead6);
        testLeads.add(lead7);

        insert testLeads;

        // Call the trigger handler method
        LeadTriggerHandler handler = new LeadTriggerHandler(true, 200);
        handler.handleTitleNormalization(testLeads);

        // Assert that the titles were normalized correctly
        System.assertEquals('Vice President', lead1.Title);
        System.assertEquals('Manager', lead2.Title);
        System.assertEquals('Executive', lead6.Title);
        System.assertEquals('Assistant', lead7.Title);
    }

    @isTest
    static void testHandleAutoLeadScoring() {
        // Create test data (Leads)
        List<Lead> testLeads = new List<Lead>();
        // Add your test data here (e.g., create Leads with different LeadSource, Email, and Industry values)
        Lead lead1 = new Lead(LeadSource = 'Web', Email = 'test@example.com', LastName = 'Test0', Company = 'Testing Company1');
        Lead lead2 = new Lead(Phone = '123-456-7890', LastName = 'Test1', Industry = 'Technology', Company = 'Testing Company2');
        Lead lead3 = new Lead(LeadSource = 'PPC', LastName = 'Test2', Industry = 'Technology', Company = 'Testing Company3');
        Lead lead4 = new Lead(Industry = 'Technology', LastName = 'Test4', Company = 'Testing Company4');
        testLeads.add(lead1);
        testLeads.add(lead2);
        testLeads.add(lead3);
        testLeads.add(lead4);

        insert testLeads;

        // Call the trigger handler method
        LeadTriggerHandler handler = new LeadTriggerHandler(true, 200);
        handler.handleAutoLeadScoring(testLeads);

        // Assert that the Lead_Score__c field was calculated correctly
        System.assertEquals(3, lead1.Lead_Score__c);
        System.assertEquals(15, lead2.Lead_Score__c);
        System.assertEquals(10, lead3.Lead_Score__c);
    }

    @isTest
    static void testHandleLeadAutoConvert() {
        //Create tes data (Accounts)        
        Account testAccount1 = new Account(Name = 'Test Account');

        insert testAccount1;

        List<Contact> testContacts = new List<Contact>();
        // Add your test data here (e.g., create Contacts with matching email addresses)
        Contact Contact1 = new Contact(LastName = 'Test1', Email = 'test1@test.com', AccountId = testAccount1.Id);
        Contact Contact2 = new Contact(LastName = 'Test2', Email = 'test2@test.com', AccountId = testAccount1.Id);
        Contact Contact3 = new Contact(LastName = 'Test3', Email = 'test2@test.com', AccountId = testAccount1.Id);
       
        testContacts.add(contact1);
        testContacts.add(contact2);
        testContacts.add(contact3);

        insert testContacts;
        // Create test data (Leads and Contacts)
        List<Lead> testLeads = new List<Lead>();
        // Add your test data here (e.g., create Leads with email addresses)
        Lead Lead1 = new Lead(LastName = 'Testing', Company = 'Test Company1', Status = 'Open - Not Contacted', Email = 'test1@test.com');
        Lead Lead2 = new Lead(LastName = 'Test2', Company = 'Test Company2', Status = 'Open - Not Contacted', Email = 'test2@test.com');
        Lead Lead3 = new Lead(LastName = 'Test3', Company = 'Test Company3', Status = 'Open - Not Contacted', Email = 'test3@test.com');
        testLeads.add(lead1);
        testLeads.add(lead2);
        testLeads.add(lead3);

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Test.startTest();
        Database.insert(testleads, dml);
        Test.stopTest();


        List<Lead> convertedLeads = [SELECT Id, IsConverted, Email FROM Lead WHERE Id = :testLeads];
       
        for (Lead testLead : convertedLeads) {
            if (testLead.Email == 'test1@test.com') {
                System.assertEquals(true, testLead.IsConverted, 'The lead should be converted.');
            }
            if (testLead.Email == 'test2@test.com') {
                System.assertEquals(false, testLead.IsConverted, 'The lead should not be converted.');
            }
            if (testLead.Email == 'test3@test.com') {
                System.assertEquals(false, testLead.IsConverted, 'The lead should not be converted.');
            }
        }      

    }
}
