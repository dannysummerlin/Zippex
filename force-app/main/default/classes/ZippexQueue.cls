public class ZippexQueue implements Queueable {
  private List<ZippexAction.ZippexInput> zippexParams;
  public ZippexQueue(List<ZippexAction.ZippexInput> zippexParams) { this.zippexParams = zippexParams; }
  public void execute(QueueableContext context) {
    List<ZippexOutput> outputRecords = new List<ZippexOutput>();
    List<Messaging.SingleEmailMessage> notificationQueue = new List<Messaging.SingleEmailMessage>();
    try {
      for (Integer ii = this.zippexParams.size() - 1; ii >= 0 ; ii--) {
        Zippex ZipFile = new Zippex();
        if(this.zippexParams[ii].fileName == null) {
            this.zippexParams[ii].fileName = 'download.zip';
        } else if(!this.zippexParams[ii].fileName.toLowerCase().contains('.zip')) {
            this.zippexParams[ii].fileName = this.zippexParams[ii].fileName + '.zip';
        }
        if(this.zippexParams[ii].expireDate == null) {
            this.zippexParams[ii].expireDate = DateTime.Now().AddDays(7);
        }
        ZipFile.addContentVersions(this.zippexParams[ii].contentVersionIds);
        ZippexOutput file = new ZippexOutput();
        file.fileName = this.zippexParams[ii].fileName;
        file.email = this.zippexParams[ii].email;
        file.expireDate = this.zippexParams[ii].expireDate;
        file.fileUrl = ZipFile.downloadZipArchive(this.zippexParams[ii].fileName, this.zippexParams[ii].expireDate);
        outputRecords.add(file);
      }
      // Database.insertImmediate((List<sObject>)outputRecords);
      for (Integer ii = outputRecords.size() - 1; ii >= 0; ii--) {
        Messaging.SingleEmailMessage notification = new Messaging.SingleEmailMessage();
        notification.setToAddresses(new List<String> { outputRecords[ii].email });
        notification.setReplyTo('noreply@zippex.app');
        notification.setSenderDisplayName('Zippex File Generator');
        notification.setSubject('Zip File Created: ' + outputRecords[ii].fileName);
        notification.setBccSender(false);
        notification.setUseSignature(false);
        notification.setPlainTextBody('Your zip file has been created: ' + outputRecords[ii].fileUrl);
        notification.setHtmlBody('Your zip file <b> ' + outputRecords[ii].fileName +' </b>has been created.<p>'+
         'To view your file <a href="' + outputRecords[ii].fileUrl + '">click here.</a>');
        notificationQueue.add(notification);
      }
      Messaging.sendEmail(notificationQueue);
    } catch (Exception e) {
      System.debug('ERROR CAUGHT');
      System.debug('Exception: ' + e.getTypeName() + ', ' + e.getMessage());
    }
  }
  public class ZippexOutput {
    public String fileName;
    public String email;
    public DateTime expireDate;
    public String fileUrl;
  }
}