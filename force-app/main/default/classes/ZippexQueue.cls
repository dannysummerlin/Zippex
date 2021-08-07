public class ZippexQueue implements Queueable {
  public class ZippexException extends Exception {}
  private List<ZippexAction.ZippexInput> zippexParams;
  public ZippexQueue(List<ZippexAction.ZippexInput> zippexParams) { this.zippexParams = zippexParams; }
  public void execute(QueueableContext context) {
    List<Messaging.SingleEmailMessage> notificationQueue = new List<Messaging.SingleEmailMessage>();
    for (Integer ii = this.zippexParams.size() - 1; ii >= 0 ; ii--) {
      Zippex ZipFile = new Zippex();
      this.zippexParams[ii].fileName = (this.zippexParams[ii].fileName == null) ? 'download.zip' : this.zippexParams[ii].fileName;
      this.zippexParams[ii].fileName += (!this.zippexParams[ii].fileName.toLowerCase().contains('.zip')) ? '.zip' : '';
      this.zippexParams[ii].expireDate = (this.zippexParams[ii].expireDate == null) ? DateTime.Now().AddDays(7) : this.zippexParams[ii].expireDate;
      this.zippexParams[ii].senderEmail = (this.zippexParams[ii].senderEmail == null) ? 'noreply@zippex.app' : this.zippexParams[ii].senderEmail;
      Messaging.SingleEmailMessage notification = new Messaging.SingleEmailMessage();
      notification.setToAddresses(new List<String> { this.zippexParams[ii].targetEmail });
      notification.setReplyTo(this.zippexParams[ii].senderEmail);
      notification.setSenderDisplayName('Zippex File Generator');
      notification.setBccSender(false);
      notification.setUseSignature(false);
      try {
        ZipFile.addContentVersions(this.zippexParams[ii].contentVersionIds);
        String fileUrl = ZipFile.downloadZipArchive(this.zippexParams[ii].fileName, this.zippexParams[ii].expireDate);
        notification.setSubject('Zip File Created: ' + this.zippexParams[ii].fileName);
        notification.setPlainTextBody('Your zip file has been created: ' + fileUrl);
        notification.setHtmlBody('Your zip file <b> ' + this.zippexParams[ii].fileName +' </b>has been created.<p>'+
         'To view your file <a href="' + fileUrl + '">click here.</a>');
      } catch (Exception e) {
        System.debug(e);
        String errorDetails = 'Exception: ' + e.getTypeName() + ', ' + e.getMessage();
        notification.setSubject('Error creating zip file: ' + this.zippexParams[ii].fileName);
        notification.setPlainTextBody('There was an error creating your zip file: ' + errorDetails);
        notification.setHtmlBody('<p>There was an error creating your zip file <b> ' + this.zippexParams[ii].fileName +' </b>:</p>'+
         '<pre>' + errorDetails + '</pre>');
        System.debug(errorDetails);
      }
      notificationQueue.add(notification);
      this.zippexParams.remove(ii);
    }
    Messaging.sendEmail(notificationQueue);
  }
}