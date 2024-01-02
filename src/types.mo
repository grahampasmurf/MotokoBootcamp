import Principal "mo:base/Principal";
import Time "mo:base/Time";
module {

    public type Stats = {
        name : Text; // The name of the DAO;
        logo: Blob; // The logo of the DAO - encoded as a PNG
        picture : Blob; // A picture reprenting the DAO - encoded as a PNG
        numberOfMembers : Nat; // The number of members in the DAO
        manifesto : Text; // The manifesto of the DAO
        socialLinkDAO: Text; // An URL to the DAO's social media page (e.g. Twitter/ OpenChat / Discord / Telegram / DAO's website)
        socialLinkBuilder: Text; // An URL to the DAO's creator social media page (e.g. Twitter/ OpenChat / Personal Blog)
    };

    public type Role = {
        #Student;
        #Graduate;
        #Mentor;
    };

    public type Member = {
        name : Text;
        role : Role;
    };

    public type ProposalId = Nat;

    public type ProposalContent = {
        #ChangeManifesto : Text; // Change the manifesto to the provided text
        #AddMentor : Principal; // Upgrade the member to a mentor with the provided principal 
    };

    public type ProposalStatus = {
        #Open;
        #Accepted;
        #Rejected;
    };

    public type Vote = {
        member : Principal; // The member who voted
        vote : Bool; // true = yes, false = no
    };

    public type Proposal = {
        content : ProposalContent; // The content of the proposal
        creator : Principal; // The member who created the proposal
        created : Time.Time; // The time the proposal was created
        executed : ?Time.Time; // The time the proposal was executed or null if not executed
        votes : [Vote]; // The votes on the proposal so far 
        status : ProposalStatus;  // The current status of the proposal
    };

    public type HeaderField = (Text, Text);
    public type HttpRequest = {
        body : Blob;
        headers : [HeaderField];
        method : Text;
        url : Text;
    };

    public type HttpResponse = {
        body : Blob;
        headers : [HeaderField];
        status_code : Nat16;
        streaming_strategy : ?StreamingStrategy;
    };

    public type StreamingStrategy = {
        #Callback : {
            callback : StreamingCallback;
            token : StreamingCallbackToken;
        };
    };

    public type StreamingCallback = query (StreamingCallbackToken) -> async (StreamingCallbackResponse);

    public type StreamingCallbackToken = {
        content_encoding : Text;
        index : Nat;
        key : Text;
    };

    public type StreamingCallbackResponse = {
        body : Blob;
        token : ?StreamingCallbackToken;
    };
}