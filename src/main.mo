import Result "mo:base/Result";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import TrieMap "mo:base/TrieMap";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Account "account";
import Option "mo:base/Option";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Types "types";

actor DAO {

    type Result<A, B> = Result.Result<A, B>;
    type Member = Types.Member;
    type ProposalContent = Types.ProposalContent;
    type ProposalId = Types.ProposalId;
    type Proposal = Types.Proposal;
    type Vote = Types.Vote;
    type HttpRequest = Types.HttpRequest;
    type HttpResponse = Types.HttpResponse;

    stable var manifesto = "Your really AWESOME manifesto";
    stable let name = "Your really AWESOME DAO";

    public type HashMap<A, B> = HashMap.HashMap<A, B>;

    var nextProposalId : Nat = 0;
    let proposals = TrieMap.TrieMap<ProposalId, Proposal>(Nat.equal, Hash.hash);
    let dao : HashMap<Principal, Member> = HashMap.HashMap<Principal, Member>(0, Principal.equal, Principal.hash);

    public type Subaccount = Blob;
    public type Account = {
        owner : Principal;
        subaccount : ?Subaccount;
    };

    let ledger : TrieMap.TrieMap<Account, Nat> = TrieMap.TrieMap(Account.accountsEqual, Account.accountsHash);

    type Status = {
        #Open;
        #Accepted;
        #Rejected;
    };

    // Returns the name of the DAO
    public query func getName() : async Text {
        return name;
    };

    // Returns the manifesto of the DAO
    public query func getManifesto() : async Text {
        return manifesto;
    };

    // Register a new member in the DAO with the given name and principal of the caller
    // Also airdrop 100 MBC tokens to the new member
    // New members are always Student
    // Returns an error if the member already exists
    public shared ({ caller }) func registerMember(name : Text) : async Result<(), Text> {
        switch (dao.get(caller)) {
            case (?member) return #err("Member already exists");
            case (null) {
                dao.put(
                    caller,
                    {
                        name = name;
                        role = #Student;
                    },
                );
                let defaultAccount = { owner = caller; subaccount = null };
                switch (ledger.get(defaultAccount)) {
                    case (null) ledger.put(defaultAccount, 100);
                    case (?some) ledger.put(defaultAccount, some + 100);
                };
                return #ok();
            };
        };
    };

    // Get the member with the given principal
    // Returns an error if the member does not exist
    public query func getMember(p : Principal) : async Result<Member, Text> {
        switch (dao.get(p)) {
            case (null) return #err("No member found");
            case (?member) return #ok(member);
        };
    };

    // Graduate the student with the given principal
    // Returns an error if the student does not exist or is not a student
    // Returns an error if the caller is not a mentor
    public shared ({ caller }) func graduate(student : Principal) : async Result<(), Text> {
        switch (dao.get(caller)) {
            case (?member1) {
                switch (member1.role) {
                    case (#Mentor) {
                        switch (dao.get(student)) {
                            case (null) return #err("No member found");
                            case (?member2) {
                                switch (member2.role) {
                                    case (#Student) {
                                        let newMember = {
                                            name = member2.name;
                                            role = #Graduate;
                                        };
                                        dao.put(student, newMember);
                                        return #ok();
                                    };
                                    case (#Graduate) return #err("Already a Graduate");
                                    case (#Mentor) return #err("Already a Mentor");
                                };
                                return #err("You are not a student");
                            };
                        };
                    };
                    case (#Graduate) return #err("You are a graduate student; only mentors may do this");
                    case (#Student) return #err("You are a Student; only mentors may do this");
                };
            };
            case (null) return #err("You are not a member");
        };
    };

    func _burn(p : Principal, amount : Nat) : () {
        let defaultAccount = { owner = p; subaccount = null };
        let balance = Option.get(ledger.get(defaultAccount), 0);
        if (balance < amount) {
            assert (false);
        };
        ledger.put(defaultAccount, balance - amount);
    };

    func _isMember(p : Principal) : Bool {
        // check if p is member
        switch (dao.get(p)) {
            case (null) return false;
            case (?member) return true;
        };
    };

    func _computeVote(oldScore : Int, vote : Bool) : Int {
        // real code would have to set bounds based on Int size
        if(vote) return oldScore + 1;
        return oldScore - 1;
    };

    // Create a new proposal and returns its id
    // Returns an error if the caller is not a mentor or doesn't own at least 1 MBC token
    public shared ({ caller }) func createProposal(content : ProposalContent) : async Result<ProposalId, Text> {
        // check if caller is member
        if (not _isMember(caller)) {
            return #err("Not a member");
        };
        // check if caller has tokens
        let defaultAccount = { owner = caller; subaccount = null };
        let balance = Option.get(ledger.get(defaultAccount), 0);
        if (balance < 1) {
            return #err("Not enough tokens");
        };
        let idSaved = nextProposalId;
        let proposal : Proposal = {
            id = idSaved;
            creator = caller;
            created = Time.now();
            executed = null;
            status = #Open;
            content = content;
            votes = [{member = caller; vote = true;}];
            voteCount = 0;
        };
        proposals.put(idSaved, proposal);

        nextProposalId += 1;
        _burn(caller, 1);
        return #ok(idSaved);
    };

    // Get the proposal with the given id
    // Returns an error if the proposal does not exist
    public query func getProposal(id : ProposalId) : async Result<Proposal, Text> {
        switch (proposals.get(id)) {
            case (null) return #err("Nothing found");
            case (?proposal) return #ok(proposal);
        };
    };

    // Returns all the proposals
    public query func getAllProposal() : async [Proposal] {
        return Iter.toArray(proposals.vals());
    };

    // Vote for the given proposal
    // Returns an error if the proposal does not exist or the member is not allowed to vote
    public shared ({ caller }) func voteProposal(proposalId : ProposalId, vote : Vote) : async Result<(), Text> {
        if (not _isMember(caller)) {
            return #err("Not a member; cannot vote");
        };
        // check if caller has tokens
        let defaultAccount = { owner = caller; subaccount = null };
        let balance = Option.get(ledger.get(defaultAccount), 0);
        if (balance < 1) {
            return #err("Not enough tokens");
        };
        switch(proposals.get(proposalId)) {
            case(null) return #err("Proposal not found");
            case(?proposal) {
                if(proposal.status == #Accepted or proposal.status == #Rejected) return #err("Already voted");
                for(principal in proposal.votes.vals()) {
                    if(principal.member == caller) return #err("Already voted");
                };
                // passed all checks
                let newVoteCount = _computeVote(proposal.voteCount, vote.vote);
                _burn(caller, 1);
               // let newVote : Vote = {member = caller; vote = vote.vote;};
                if(newVoteCount == -10) {
                    let newProposal = {
                        id = proposal.id;
                        status = #Rejected;
                        content = proposal.content;
                        voteCount = newVoteCount;
                        votes = proposal.votes;
                        created = proposal.created;
                        executed = null;
                        creator = proposal.creator;
                    };
                    //  votes = Array.append<Vote>(proposal.votes, {member = caller; vote = vote.vote;});
                    proposals.put(proposal.id, newProposal);
                    return #ok();
                };
                if(newVoteCount == 10) {
                    let newProposal = {
                        id = proposal.id;
                        status = #Accepted;
                        content = proposal.content;
                        voteCount = newVoteCount;
                        votes = proposal.votes;
                        created = proposal.created;
                        executed = null;
                        creator = proposal.creator;
                    };
                    proposals.put(proposal.id, newProposal);
                    return #ok();
                };
                // else, proposal remains open
                    let newProposal = {
                        id = proposal.id;
                        status = #Open;
                        content = proposal.content;
                        voteCount = newVoteCount;
                        votes = proposal.votes;
                        created = proposal.created;
                        executed = null;
                        creator = proposal.creator;
                    };
                    proposals.put(proposal.id, newProposal);
                return #ok();
            };
        };
    };

    // Returns the webpage of the DAO when called from the browser
    public query func http_request(request : HttpRequest) : async HttpResponse {
        return ({
            status_code = 200;
            headers = [];
            body = Text.encodeUtf8(manifesto);
            streaming_strategy = null;
        });
    };

};
