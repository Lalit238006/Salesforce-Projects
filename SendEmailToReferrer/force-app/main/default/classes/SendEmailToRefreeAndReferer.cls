public class SendEmailToRefreeAndReferer {
    //Wrapper class
    public class CaseWrapper{
        @InvocableVariable
        public Id caseId;
        @InvocableVariable
        public  String refferalCode;
        @InvocableVariable
        public String Customer_Contact_email;
        @InvocableVariable
        public String approvalpicklist;
        @InvocableVariable
        public String ContactId;
    }
    
    @InvocableMethod(label='Send email to Refree/Referer' description='Send email to Refree/Referer')
    public static void sendEmailInvokedFromFlow(List<CaseWrapper> casewrapobj){
        User userObj;
        if(casewrapobj[0].refferalCode!=''){
            userObj = [SELECT Id, email,Used_Referral_Code__c from User WHERE Referral_Code__c = :casewrapobj[0].refferalCode limit 1]; 
        } 
        String[] toAddresses;
        EmailTemplate emailTemplate;
        if(casewrapobj[0].approvalpicklist=='Approve'){
            emailTemplate = [Select Id,Subject,Description, HtmlValue,DeveloperName,Body from EmailTemplate where name =:System.Label.Case_Approval_Template_Name];
            sendEmail(new String[] {casewrapobj[0].Customer_Contact_email},emailTemplate,casewrapobj[0].ContactId);
            emailTemplate = [Select Id,Subject,Description, HtmlValue,DeveloperName,Body from EmailTemplate where name =:System.Label.Redeem_Product_Email_Template];
        	sendEmail(new String[] {userObj.email},emailTemplate,casewrapobj[0].ContactId);
        }else{
            emailTemplate = [Select Id,Subject,Description, HtmlValue,DeveloperName,Body from EmailTemplate where name =:System.Label.Case_Rejection_Template_Name];
            sendEmail(new String[] {casewrapobj[0].Customer_Contact_email},emailTemplate,casewrapobj[0].ContactId);
        }
    }
    
    public static void sendEmail(String[] toAddresses,EmailTemplate emailTemplate,String TargetObjectId){        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = toAddresses;
        message.optOutPolicy = 'FILTER';        
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(TargetObjectId);
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }   
    }
    
}