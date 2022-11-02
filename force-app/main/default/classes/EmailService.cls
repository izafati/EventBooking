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
    return results;
  }
}
