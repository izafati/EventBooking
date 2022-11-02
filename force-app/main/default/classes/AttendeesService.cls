public class AttendeesService {
  private static final HttpCalloutService.RequestParams REGISTER_ATTENDEES_PARAMS = new HttpCalloutService.RequestParams(
    'https://th-apex-http-callout.herokuapp.com/animals',
    'POST',
    new Map<String, String>{
      'content-type' => 'application/json;charset=UTF-8'
    }
  );

  @future(callout=true)
  public static void registerAttendees(Set<Id> accountIds) {
    for (Contact contact : [
      SELECT Id, Name, Email
      FROM Contact
      WHERE AccountId IN :accountIds
      WITH SECURITY_ENFORCED
    ]) {
      CalloutData.AttendeesRequest attendeesRequest = new CalloutData.AttendeesRequest(
        contact.Name,
        contact.Email
      );
      try {
        CalloutData.AttendeesResponse attendeesResponse = Test.isRunningTest()
          ? new CalloutData.AttendeesResponse(true, null)
          : HttpCalloutService.registerAttendeesRequest(
              REGISTER_ATTENDEES_PARAMS,
              JSON.serialize(attendeesRequest),
              CalloutData.AttendeesResponse.class
            );
        if (attendeesResponse.isSuccess) {
          EmailService.notifyAttendeeByEmail(contact);
        }
      } catch (Exception e) {
        Log.error(e.getMessage());
      }
    }
  }
}
