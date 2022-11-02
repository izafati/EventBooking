public class HttpCalloutService {
  public class HttpCalloutServiceException extends Exception {
  }

  private static final String CALLOUT_ERROR = 'Callout not invoked since endpoint or method is missing';

  public static CalloutData.AttendeesResponse registerAttendeesRequest(
    RequestParams params,
    String jsonBody,
    System.Type responseType
  ) {
    CalloutData.AttendeesResponse attendeesResponse = null;
    if (!validateParams(params)) {
      throw new HttpCalloutServiceException(CALLOUT_ERROR);
    }
    HttpRequest request = new HttpRequest();
    request.setEndpoint(params.endpoint);
    request.setBody(jsonBody);
    request.setMethod(params.method);
    for (String headerName : params.headers.keySet()) {
      request.setHeader(headerName, params.headers.get(headerName));
    }
    HttpResponse response = new Http().send(request);
    if (response.getStatusCode() != 201) {
      attendeesResponse = new CalloutData.AttendeesResponse(
        false,
        (responseType <> null
          ? JSON.deserialize(response.getBody(), responseType)
          : response.getBody())
      );
    } else {
      attendeesResponse = new CalloutData.AttendeesResponse(
        true,
        (responseType <> null
          ? JSON.deserialize(response.getBody(), responseType)
          : response.getBody())
      );
    }
    return attendeesResponse;
  }

  private static Boolean validateParams(RequestParams params) {
    return String.isNotBlank(params.endpoint) &&
      String.isNotBlank(params.method);
  }

  public class RequestParams {
    public String endpoint { get; set; }
    public String method { get; set; }
    public Map<String, String> headers { get; set; }
    public RequestParams(
      String endpoint,
      String method,
      Map<String, String> headers
    ) {
      this.endpoint = endpoint;
      this.method = method;
      this.headers = headers;
    }
  }
}
