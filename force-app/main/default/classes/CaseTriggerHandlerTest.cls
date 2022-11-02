@isTest
public class CaseTriggerHandlerTest {
  private static final String SALESFORCE_ACCOUNT = 'Salesforce';

  @TestSetup
  private static void setupData() {
    Account salesforceAccount = (Account) TestDataFactory.createSObject(
      'Account',
      new Map<String, Object>{ 'Name' => SALESFORCE_ACCOUNT },
      true
    );
  }
  @isTest
  public static void refuseCaseCreationWhenAnAccountIsNotAttachedToACase() {
    // Given
    Case request = (Case) TestDataFactory.createSObject(
      'Case',
      new Map<String, Object>{
        'Origin' => 'Phone',
        'Subject' => 'Event Booking',
        'Description' => 'Book Spots'
      },
      false
    );

    // When

    Test.startTest();

    Database.SaveResult result = Database.insert(request, false);

    Test.stopTest();

    // Then

    System.assert(!result.isSuccess());
    System.assert(result.getErrors().size() > 0);
    System.assertEquals(
      CaseTriggerHelper.EMPTY_ACCOUNT_ID,
      result.getErrors()[0].getMessage(),
      'System should add error to case when there no related account.'
    );
  }

  @isTest
  public static void refuseCaseCreationWhenNoContactIsAttachedToAnAccount() {
    // Given
    Account salesforceAccount = [
      SELECT Id
      FROM Account
      WHERE Name = :SALESFORCE_ACCOUNT
      LIMIT 1
    ];
    System.assertNotEquals(
      null,
      salesforceAccount,
      'We do not have a valid account for the test context.'
    );

    Case request = (Case) TestDataFactory.createSObject(
      'Case',
      new Map<String, Object>{
        'Origin' => 'Phone',
        'Subject' => 'Event Booking',
        'Description' => 'Book Spots',
        'AccountId' => salesforceAccount.ID
      },
      false
    );

    // When

    Test.startTest();

    Database.SaveResult result = Database.insert(request, false);

    Test.stopTest();

    // Then

    System.assert(!result.isSuccess());
    System.assert(result.getErrors().size() > 0);
    System.assertEquals(
      CaseTriggerHelper.EMPTY_CONTACTS,
      result.getErrors()[0].getMessage(),
      'System should add error to case when there are not related contacts.'
    );
  }

  @isTest
  public static void bookEventFromPhone() {
    // Given
    Account salesforceAccount = [
      SELECT Id
      FROM Account
      WHERE Name = :SALESFORCE_ACCOUNT
      LIMIT 1
    ];
    System.assertNotEquals(
      null,
      salesforceAccount,
      'We do not have a valid account for the test context.'
    );

    Contact contact1 = (Contact) TestDataFactory.createSObject(
      'Contact',
      new Map<String, Object>{
        'LastName' => 'Contact 1',
        'AccountId' => salesforceAccount.ID
      },
      false
    );

    Contact contact2 = (Contact) TestDataFactory.createSObject(
      'Contact',
      new Map<String, Object>{
        'LastName' => 'Contact 2',
        'AccountId' => salesforceAccount.ID
      },
      false
    );

    Contact contact3 = (Contact) TestDataFactory.createSObject(
      'Contact',
      new Map<String, Object>{
        'LastName' => 'Contact 3',
        'AccountId' => salesforceAccount.ID
      },
      false
    );
    List<Contact> testContacts = new List<Contact>{
      contact1,
      contact2,
      contact3
    };
    insert testContacts;

    Case request = (Case) TestDataFactory.createSObject(
      'Case',
      new Map<String, Object>{
        'Origin' => 'Phone',
        'Subject' => 'Event Booking',
        'Description' => 'Book Spots for Company A1 & their 3 employees',
        'AccountId' => salesforceAccount.ID
      },
      false
    );

    // When

    Test.startTest();

    Database.SaveResult result = Database.insert(request, false);
    Test.stopTest();

    // Then

    System.assert(
      result.isSuccess(),
      'System should not add error to phone case.'
    );
  }

  @isTest
  public static void refuseEventBookingWhenNumberOfAttendeesIsMoreThanThreeForPhoneCases() {
    // Given
    Account salesforceAccount = [
      SELECT Id
      FROM Account
      WHERE Name = :SALESFORCE_ACCOUNT
      LIMIT 1
    ];
    System.assertNotEquals(
      null,
      salesforceAccount,
      'We do not have a valid account for the test context.'
    );

    Contact contact1 = (Contact) TestDataFactory.createSObject(
      'Contact',
      new Map<String, Object>{
        'LastName' => 'Contact 1',
        'AccountId' => salesforceAccount.ID
      },
      false
    );

    Contact contact2 = (Contact) TestDataFactory.createSObject(
      'Contact',
      new Map<String, Object>{
        'LastName' => 'Contact 2',
        'AccountId' => salesforceAccount.ID
      },
      false
    );

    Contact contact3 = (Contact) TestDataFactory.createSObject(
      'Contact',
      new Map<String, Object>{
        'LastName' => 'Contact 3',
        'AccountId' => salesforceAccount.ID
      },
      false
    );

    Contact contact4 = (Contact) TestDataFactory.createSObject(
      'Contact',
      new Map<String, Object>{
        'LastName' => 'Contact 4',
        'AccountId' => salesforceAccount.ID
      },
      false
    );

    List<Contact> testContacts = new List<Contact>{
      contact1,
      contact2,
      contact3,
      contact4
    };
    insert testContacts;

    Case request = (Case) TestDataFactory.createSObject(
      'Case',
      new Map<String, Object>{
        'Origin' => 'Phone',
        'Subject' => 'Event Booking',
        'Description' => 'Book Spots for Company A1 & their 4 employees',
        'AccountId' => salesforceAccount.ID
      },
      false
    );

    // When

    Test.startTest();

    Database.SaveResult result = Database.insert(request, false);

    Test.stopTest();

    // Then
    System.assert(!result.isSuccess());
    System.assert(result.getErrors().size() > 0);
    System.assertEquals(
      CaseTriggerHelper.ONLY_THREE_ATTENDEE,
      result.getErrors()[0].getMessage(),
      'System should add error to phone case when there are more than three attendees.'
    );
  }

  @isTest
  public static void bookEventFromTheWeb() {
    // Given
    Account salesforceAccount = [
      SELECT Id
      FROM Account
      WHERE Name = :SALESFORCE_ACCOUNT
      LIMIT 1
    ];
    System.assertNotEquals(
      null,
      salesforceAccount,
      'We do not have a valid account for the test context.'
    );

    Contact contact1 = (Contact) TestDataFactory.createSObject(
      'Contact',
      new Map<String, Object>{
        'LastName' => 'Contact 1',
        'AccountId' => salesforceAccount.ID
      },
      true
    );

    Case request = (Case) TestDataFactory.createSObject(
      'Case',
      new Map<String, Object>{
        'Origin' => 'Web',
        'Subject' => 'Event Booking',
        'Description' => 'Book Spots for Company A1',
        'AccountId' => salesforceAccount.ID
      },
      false
    );

    // When

    Test.startTest();

    Database.SaveResult result = Database.insert(request, false);

    Test.stopTest();

    // Then

    System.assert(
      result.isSuccess(),
      'System should not add error to web case.'
    );
  }

  @isTest
  public static void refuseEventBookingWhenNumberOfAttendeesIsMoreThanOneForWebCases() {
    // Given
    Account salesforceAccount = [
      SELECT Id
      FROM Account
      WHERE Name = :SALESFORCE_ACCOUNT
      LIMIT 1
    ];
    System.assertNotEquals(
      null,
      salesforceAccount,
      'We do not have a valid account for the test context.'
    );

    Contact contact1 = (Contact) TestDataFactory.createSObject(
      'Contact',
      new Map<String, Object>{
        'LastName' => 'Contact 1',
        'AccountId' => salesforceAccount.ID
      },
      false
    );

    Contact contact2 = (Contact) TestDataFactory.createSObject(
      'Contact',
      new Map<String, Object>{
        'LastName' => 'Contact 2',
        'AccountId' => salesforceAccount.ID
      },
      false
    );

    Contact contact3 = (Contact) TestDataFactory.createSObject(
      'Contact',
      new Map<String, Object>{
        'LastName' => 'Contact 3',
        'AccountId' => salesforceAccount.ID
      },
      false
    );

    List<Contact> testContacts = new List<Contact>{
      contact1,
      contact2,
      contact3
    };
    insert testContacts;

    Case request = (Case) TestDataFactory.createSObject(
      'Case',
      new Map<String, Object>{
        'Origin' => 'Web',
        'Subject' => 'Event Booking',
        'Description' => 'Book Spots for Company A1 & their 3 employees',
        'AccountId' => salesforceAccount.ID
      },
      false
    );
    // When

    Test.startTest();

    Database.SaveResult result = Database.insert(request, false);

    Test.stopTest();

    // Then

    System.assert(!result.isSuccess());
    System.assert(result.getErrors().size() > 0);
    System.assertEquals(
      CaseTriggerHelper.ONLY_ONE_ATTENDEE,
      result.getErrors()[0].getMessage(),
      'System should add error to web case when there are more than one attendee.'
    );
  }
}
