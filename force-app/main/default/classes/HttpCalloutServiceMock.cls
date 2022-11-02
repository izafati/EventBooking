global class HttpCalloutServiceMock implements HttpCalloutMock {
  global HTTPResponse respond(HTTPRequest req) {
    HttpResponse response = new HttpResponse();
    response.setHeader('Content-Type', 'application/json');
    response.setBody('{"name":"contact 1"}');
    response.setStatusCode(201);
    return response;
  }
}
