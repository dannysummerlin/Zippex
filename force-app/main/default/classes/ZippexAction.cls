public class ZippexAction {
    // Accepts list of ContentVersions and builds zip archive, then returns the value for download
    @InvocableMethod(label='Zip and download from a list of ContentVersion Ids (has a default link expiration of 7 days)')
    static public List<String> downloadContentVersionList(List<ZippexInput> zippexParams) {
        List<String> jobIDs = new List<String>();
        ZippexQueue queue = new ZippexQueue(zippexParams);
        ID jobID = System.enqueueJob(queue);
        jobIDs.add(String.valueOf(jobID));
        return jobIDs;
    }

// Apex-defined data type to specify expiration and filename
    public class ZippexInput {
        @AuraEnabled @InvocableVariable(label='ContentVersion ID Collection' description='A collection of ContentVersion IDs to zip together' required=true)
        public List<String> contentVersionIds;
        @AuraEnabled @InvocableVariable(label='Target Email' description='The notification email target' required=true)
        public String targetEmail;
        @AuraEnabled @InvocableVariable(label='Sender Email' description='The notification email target')
        public String senderEmail;
        @AuraEnabled @InvocableVariable(label='Zip File Name')
        public String fileName;
        @AuraEnabled @InvocableVariable(label='Public Link Expiration' description='By default 7 days after generating the link it will expire, but you can set a more specific date')
        public DateTime expireDate;
    }
}