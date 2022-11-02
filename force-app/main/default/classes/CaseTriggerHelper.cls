public class CaseTriggerHelper {
  @TestVisible
  private static final String EMPTY_ACCOUNT_ID = 'You cannot create a request without attaching an account';
  @TestVisible
  private static final String EMPTY_CONTACTS = 'You cannot create a request for accounts without contacts';
  @TestVisible
  private static final String ONLY_ONE_ATTENDEE = 'Web request are only allowed to have one attendee';
  @TestVisible
  private static final String ONLY_THREE_ATTENDEE = 'Phone request are only allowed to have three attendee';

  public static void appendErrorToCases(List<Case> cases) {
    Set<Id> accountIds = getAccountIds(cases);
    Map<Id, Account> accountMaps = new Map<Id, Account>(
      [
        SELECT ID, (SELECT id FROM contacts)
        FROM Account
        WHERE id IN :accountIds
        WITH SECURITY_ENFORCED
      ]
    );

    for (Case hotelCase : cases) {
      try {
        hotelCase.addError(getErrorMessage(hotelCase, accountMaps));
      } catch (exception e) {
        Log.error(e.getMessage());
      }
    }
  }

  private static String getErrorMessage(
    Case hotelCase,
    Map<Id, Account> accountMap
  ) {
    Id accountId = hotelCase?.AccountId;
    String errorMessage = accountId == null
      ? EMPTY_ACCOUNT_ID
      : getErrorMessageByOrigin(hotelCase.Origin, accountMap.get(accountId));
    return errorMessage;
  }

  private static String getErrorMessageByOrigin(
    String origin,
    Account account
  ) {
    String errorMessage;
    Integer accountContactsSize = account?.Contacts?.size();
    if (accountContactsSize == 0) {
      errorMessage = EMPTY_CONTACTS;
    } else if (origin == CTE.CASE_ORIGIN_WEB && accountContactsSize >= 2) {
      errorMessage = ONLY_ONE_ATTENDEE;
    } else if (origin == CTE.CASE_ORIGIN_PHONE && accountContactsSize >= 4) {
      errorMessage = ONLY_THREE_ATTENDEE;
    }
    return errorMessage;
  }

  private static Set<Id> getAccountIds(List<Case> cases) {
    Set<Id> accountIds = new Set<Id>();
    for (Case hotelCase : cases) {
      accountIds.add(hotelCase.AccountId);
    }
    return accountIds;
  }

  public static void registerAttendees(Map<Id, Case> caseMap) {
    Set<Id> caseIds = caseMap.keySet();
    List<Case> cases = [
      SELECT AccountId, Status
      FROM Case
      WHERE id IN :caseIds AND Status = :CTE.CASE_STATUS_CLOSED
      WITH SECURITY_ENFORCED
    ];
    Set<Id> accountIds = new Set<Id>();
    for (Case hotelCase : cases) {
      //   ExternalSystemService service = new ExternalSystemService();
      //   service.registerAttendees(hotelCase);
      accountIds.add(hotelCase.AccountId);
    }
    AttendeesService.registerAttendees(accountIds);
  }
}
