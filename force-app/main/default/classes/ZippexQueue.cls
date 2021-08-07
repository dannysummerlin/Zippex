public class ZippexQueue implements Queueable {
  private List<ZippexAction.ZippexInput> zippexParams;
  public ZippexQueue(List<ZippexAction.ZippexInput> zippexParams) {
    this.zippexParams = zippexParams;
  }
  public void execute(QueueableContext context) {
    List<Zippex_ZipFile__c> outputRecords = new List<Zippex_ZipFile__c>();
    List<Messaging.Email> notificationQueue = new List<Messaging.Email>();
    // Finalizer finalizer = new ZippexQueue();
    // System.attachFinalizer(finalizer);
    try {
      for (Integer jj = this.zippexParams.size() - 1; jj >= 0 ; jj--) {
        Zippex ZipFile = new Zippex();
        if(this.zippexParams[jj].fileName == null) {
            this.zippexParams[jj].fileName = 'download.zip';
        } else if(!this.zippexParams[jj].fileName.toLowerCase().contains('.zip')) {
            this.zippexParams[jj].fileName = this.zippexParams[jj].fileName + '.zip';
        }
        if(this.zippexParams[jj].expireDate == null) {
            this.zippexParams[jj].expireDate = DateTime.Now().AddDays(7);
        }
        ZipFile.addContentVersions(this.zippexParams[jj].contentVersionIds);
        Zippex_ZipFile__c file = new Zippex_ZipFile__c();
        file.Name = this.zippexParams[jj].fileName;
        file.NotificationEmail__c = this.zippexParams[jj].email;
        file.FileURL__c = ZipFile.downloadZipArchive(this.zippexParams[jj].fileName, this.zippexParams[jj].expireDate);
        outputRecords.add(file);
      }
      Database.insertImmediate((List<sObject>)outputRecords);
      for (Integer ii = outputRecords.size() - 1; ii >= 0; ii++) {
        Messaging.SingleEmailMessage notification = new Messaging.SingleEmailMessage();
        notification.setToAddresses(new List<String> { outputRecords[ii].NotificationEmail__c });
        notification.setReplyTo('zippex@salesforce.com');
        notification.setSenderDisplayName('Zippex File Generator');
        notification.setSubject('Zip File Created: ' + outputRecords[ii].Name);
        notification.setBccSender(false);
        notification.setUseSignature(false);
        String fileURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + outputRecords[ii].Id;
        notification.setPlainTextBody('Your zip file has been created: ' + fileURL);
        notification.setHtmlBody('Your zip file <b> ' + outputRecords[ii].Name +' </b>has been created.<p>'+
         'To view your file <a href="' + fileURL + '">click here.</a>');
      }
      Messaging.sendEmail(notificationQueue);
    } catch (Exception e) {
      System.debug('Exception: ' + e.getTypeName() + ', ' + e.getMessage());
    }
  }
}