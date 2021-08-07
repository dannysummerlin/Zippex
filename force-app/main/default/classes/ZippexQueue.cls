public class ZippexQueue implements Queueable {
  private List<ZippexAction.ZippexInput> zippexParams;
  public ZippexQueue(List<ZippexAction.ZippexInput> zippexParams) { this.zippexParams = zippexParams; }
  public void execute(QueueableContext context) {
    List<Zippex_ZipFile__c> outputRecords = new List<Zippex_ZipFile__c>();
    List<Messaging.Email> notificationQueue = new List<Messaging.Email>();
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
        Zippex_ZipFile__c file = new Zippex_ZipFile__c();
        file.Name = this.zippexParams[ii].fileName;
        file.NotificationEmail__c = this.zippexParams[ii].email;
        file.ContentVersionIDs__c = String.join(this.zippexParams[ii].contentVersionIds, ', ');
        file.FileURL__c = ZipFile.downloadZipArchive(this.zippexParams[ii].fileName, this.zippexParams[ii].expireDate);
        outputRecords.add(file);
      }
      Database.insertImmediate((List<sObject>)outputRecords);
      for (Integer ii = outputRecords.size() - 1; ii >= 0; ii--) {
        Messaging.SingleEmailMessage notification = new Messaging.SingleEmailMessage();
        notification.setToAddresses(new List<String> { outputRecords[ii].NotificationEmail__c });
        notification.setReplyTo('noreply@zippex.app');
        notification.setSenderDisplayName('Zippex File Generator');
        notification.setSubject('Zip File Created: ' + outputRecords[ii].Name);
        notification.setBccSender(false);
        notification.setUseSignature(false);
        notification.setPlainTextBody('Your zip file has been created: ' + outputRecords[ii].FileURL__c);
        notification.setHtmlBody('Your zip file <b> ' + outputRecords[ii].Name +' </b>has been created.<p>'+
         'To view your file <a href="' + outputRecords[ii].FileURL__c + '">click here.</a>');
        notificationQueue.add(notificationQueue);
      }
      Messaging.sendEmail(notificationQueue);
    } catch (Exception e) {
      System.debug('ERROR CAUGHT');
      System.debug('Exception: ' + e.getTypeName() + ', ' + e.getMessage());
    }
  }
}