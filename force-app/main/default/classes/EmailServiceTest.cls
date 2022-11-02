@IsTest
public class EmailServiceTest {
  private static final String PERSONAL_ACCOUNT = 'personal';

  @TestSetup
  private static void setupData() {
    Account personalAccount = (Account) TestDataFactory.createSObject(
      'Account',
      new Map<String, Object>{ 'Name' => PERSONAL_ACCOUNT },
      true
    );
  }

  @IsTest
  public static void ShouldNotifyAttendeesByEmailSucessfully() {
    Account personalAccount = [
      SELECT Id
      FROM Account
      WHERE Name = :PERSONAL_ACCOUNT
      LIMIT 1
    ];
    System.assertNotEquals(
      null,
      personalAccount,
      'We do not have a valid account for the test context.'
    );

    Contact contact1 = (Contact) TestDataFactory.createSObject(
      'Contact',
      new Map<String, Object>{
        'LastName' => 'Contact 1',
        'Email' => 'test.contact1@email.test.xyz',
        'AccountId' => personalAccount.ID
      },
      true
    );

    Test.startTest();
    Messaging.SendEmailResult[] results = EmailService.notifyAttendeeByEmail(
      contact1
    );
    Test.stopTest();

    System.assertEquals(
      results[0].success,
      true,
      'Email should be sent to contact.'
    );
  }

  @IsTest
  public static void ShouldNotNotifyAttendeesByEmailSucessfully() {
    Account personalAccount = [
      SELECT Id
      FROM Account
      WHERE Name = :PERSONAL_ACCOUNT
      LIMIT 1
    ];
    System.assertNotEquals(
      null,
      personalAccount,
      'We do not have a valid account for the test context.'
    );

    Contact contact1 = (Contact) TestDataFactory.createSObject(
      'Contact',
      new Map<String, Object>{
        'LastName' => 'Contact 1',
        'AccountId' => personalAccount.ID
      },
      true
    );

    Exception emailException;
    Messaging.SendEmailResult[] results;
    Test.startTest();
    try {
      results = EmailService.notifyAttendeeByEmail(contact1);
    } catch (Exception e) {
      emailException = e;
    }
    Test.stopTest();
    System.assertNotEquals(
      emailException,
      null,
      'an exception should be thrown.'
    );
  }
}
