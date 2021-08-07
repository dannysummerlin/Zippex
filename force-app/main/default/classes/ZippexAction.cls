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
        @AuraEnabled @InvocableVariable
        public String fileName;
        @AuraEnabled @InvocableVariable(description='The notification email target')
        public String email;
        @AuraEnabled @InvocableVariable
        public List<String> contentVersionIds;
        @AuraEnabled @InvocableVariable
        public DateTime expireDate;
    }
}