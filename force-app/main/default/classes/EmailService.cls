public class EmailService {
  public static Messaging.SendEmailResult[] notifyAttendeeByEmail(
    Contact contact
  ) {
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    message.toAddresses = new List<String>{ contact.Email };
    message.optOutPolicy = 'FILTER';
    message.subject = 'Send Email To' + contact.name;
    message.plainTextBody = 'Email sent to notify attendee!';
    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
      message
    };
    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

    if (results[0].success) {
      System.debug('The email was sent successfully.');
    } else {
      System.debug('The email failed to send: ' + results[0].errors[0].message);
    }

    return results;
  }
}
