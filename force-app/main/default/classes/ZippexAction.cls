public class ZippexAction {
    // Accepts list of ContentVersions and builds zip archive, then returns the value for download
    @InvocableMethod(label='Zip and download from a list of ContentVersion Ids (has a default link expiration of 7 days)')
    static public List<String> downloadContentVersionList(List<ZippexInput> zippexParams) {
        List<String> outputUrls = new List<String>();
        for (Integer i = zippexParams.size() - 1; i >= 0 ; i--) {
            Zippex ZipFile = new Zippex();
            if(zippexParams[i].fileName == null) {
                zippexParams[i].fileName = 'download.zip';
            } else if(!zippexParams[i].fileName.toLowerCase().contains('.zip')) {
                zippexParams[i].fileName = zippexParams[i].fileName + '.zip';
            }
            if(zippexParams[i].expireDate == null) {
                zippexParams[i].expireDate = DateTime.Now().AddDays(7);
            }
            ZipFile.addContentVersions(zippexParams[i].contentVersionIds);
            outputUrls.add(ZipFile.downloadZipArchive(zippexParams[i].fileName, zippexParams[i].expireDate));
        }
        return outputUrls;
    }

// Apex-defined data type to specify expiration and filename
    public class ZippexInput {
        @AuraEnabled @InvocableVariable
        public String fileName;
        @AuraEnabled @InvocableVariable
        public List<String> contentVersionIds;
        @AuraEnabled @InvocableVariable
        public DateTime expireDate;
    }
}