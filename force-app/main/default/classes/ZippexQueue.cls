public class ZippexQueue implements Queueable {
  private List<ZippexAction.ZippexInput> zippexParams;
  public ZippexQueue(List<ZippexAction.ZippexInput> zippexParams) { this.zippexParams = zippexParams; }
  public void execute(QueueableContext context) {
    List<Messaging.SingleEmailMessage> notificationQueue = new List<Messaging.SingleEmailMessage>();
    try {
      for (Integer ii = this.zippexParams.size() - 1; ii >= 0 ; ii--) {
        Zippex ZipFile = new Zippex();
        this.zippexParams[ii].fileName = (this.zippexParams[ii].fileName == null) ? 'download.zip' : this.zippexParams[ii].fileName;
        this.zippexParams[ii].fileName += (!this.zippexParams[ii].fileName.toLowerCase().contains('.zip')) ? '.zip' : '';
        this.zippexParams[ii].expireDate = (this.zippexParams[ii].expireDate == null) ? DateTime.Now().AddDays(7) : this.zippexParams[ii].expireDate;
        this.zippexParams[ii].senderEmail = (this.zippexParams[ii].senderEmail == null) ? 'noreply@zippex.app' : this.zippexParams[ii].senderEmail;
        String fileUrl = ZipFile.downloadZipArchive(this.zippexParams[ii].fileName, this.zippexParams[ii].expireDate);
        ZipFile.addContentVersions(this.zippexParams[ii].contentVersionIds);

        Messaging.SingleEmailMessage notification = new Messaging.SingleEmailMessage();
        notification.setToAddresses(new List<String> { this.zippexParams[ii].targetEmail });
        notification.setReplyTo(this.zippexParams[ii].senderEmail);
        notification.setSenderDisplayName('Zippex File Generator');
        notification.setSubject('Zip File Created: ' + this.zippexParams[ii].fileName);
        notification.setBccSender(false);
        notification.setUseSignature(false);
        notification.setPlainTextBody('Your zip file has been created: ' + fileUrl);
        notification.setHtmlBody('Your zip file <b> ' + this.zippexParams[ii].fileName +' </b>has been created.<p>'+
         'To view your file <a href="' + fileUrl + '">click here.</a>');
        notificationQueue.add(notification);
      }
      Messaging.sendEmail(notificationQueue);
    } catch (Exception e) {
      System.debug('ERROR CAUGHT');
      System.debug('Exception: ' + e.getTypeName() + ', ' + e.getMessage());
    }
  }
}