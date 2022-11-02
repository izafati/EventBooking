public class CalloutData {
  public class AttendeesRequest {
    public String name { get; set; }
    public String email { get; set; }
    public AttendeesRequest(String name, String email) {
      this.name = name;
      this.email = email;
    }
  }

  public class AttendeesResponse {
    public Boolean isSuccess { get; set; }
    public object response { get; set; }
    public AttendeesResponse(Boolean isSuccess, Object response) {
      this.isSuccess = isSuccess;
      this.response = response;
    }
  }
}
