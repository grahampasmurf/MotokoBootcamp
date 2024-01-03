# Motoko Bootcamp - DAO Adventure - Graduation

<p align="center"><img src="./assets/cover_1.webp" /></p>

> This repository correspond to the graduation phase of the DAO Adventure. To check out the complete DAO Adventure repository, [click here](https://github.com/motoko-bootcamp/dao-adventure).

## Motivation 💭

A DAO, which stands for Decentralized Autonomous Organization, is a new type of organization (or company) that runs leveraging blockchain technology. This enables us to create more transparent, trusted and efficient organisations.

<p align="center"><img src="./assets/cover_2.png" /></p>

**DAOs** are the biggest innovation in the field of governance since the invention of the [LLC](https://www.investopedia.com/terms/l/llc.asp) or perhaps even democracy itself. Just like the **steam engine** made the **Industrial Revolution** possible by harnessing **physical powe**r, DAOs harness **political power** and make a Web3 revolution possible. This could fundamentally change how we organize resources, people and capital with the end goal of creating a more stable, flourishing, collaborative and fair civilisation.

## Mission 🎯

This future is only possible if enough builders stand up to make the dream a reality.

Your goal, if you wish to earn your **Motoko Bootcamp Diploma**, is to build a simple DAO. <br/>

<p align="center"><img src="./assets/diploma_mbc.jpg" style="width: 500px;" /></p>

Based on all the knowledge you've acquired during your training, you should be able to build, from scratch, a simple DAO that follows the necessary requirements.

## Important resources 📌

- [Motoko Bootcamp Dashboard](https://www.motokobootcamp.com/) (Click on **Login** to access)
- [Motoko Bootcamp Discord](https://discord.gg/qEF2W3dBrd)
- [Graduation Repository](https://github.com/motoko-bootcamp/dao-adventure-graduation)
- [Graduation Notion Guide]()

## Requirements 👨‍🏫

1. **Webpage Control**: The DAO can modify text on a specific webpage. This change is based on proposals approved by DAO members.

2. **Membership and Token Allocation**:

- New members receive 10 Motoko Bootcamp Tokens (MBT) upon joining.
- MBTs are essential for participating in DAO activities.

3. **Role System**:

- The DAO comprises three roles: **Students**, **Graduates**, and **Mentors**.
- **Students**: All new members start as students. They are members who haven't completed the Motoko Bootcamp.
  Graduates: These are members who have completed the Motoko Bootcamp. They gain the right to vote on proposals. Any member can become a Graduate through a `graduate` function, which only a **Mentor** executes. There's no verification process for this.
- **Mentors**: Graduates who are selected by the DAO become **\*Mentors**. They can both vote on and create proposals. An existing Mentor can attempt to assign the Mentor role to any member by creating a proposal that has to be approved by the DAO.

4. **Proposal Creation**

- Only Mentors are authorized to create proposals.
- To create a proposal, a Mentor must burn 1 MBT, which decreases their token balance.

5. **Voting Mechanism**:

- Voting rights are exclusive to Graduates and Mentors.
- The voting power of a member is proportional to their MBT holdings.
- Proposal outcomes are determined by the cumulative MBTs:
  - Passing a Proposal: A proposal is approved if the total MBTs of supporters are 100 or more.
  - Rejecting a Proposal: A proposal is rejected if the total MBTs of opponents are 100 or more.
- There is no MBT cost for voting.

6. **Proposal Execution**:

- Approved proposals are executed automatically.

7. **Initial Setup**:
   The initial setup of the DAO includes the following members to ensure the DAO is operational from the start:

- **Mentor**:
  - Name: **motoko_bootcamp**
  - Associated Principal: `gth2f-eyaaa-aaaaj-qa2pq-cai`.
- **Student 1**:
  - Name: **Motoko**
  - Associated Principal: `4ey3h-nplzm-vyocb-xfjab-wwsos-ejl4y-27juy-qresy-emn7o-eczpl-pae`.
- **Student 2**:
  - Name: **Seb**
  - Associated Principal: `im5mh-xqo25-qfehz-urydn-n7fpm-ylmaw-n6fld-h2xdx-46pcp-tcuti-eqe`.
- **Student 3**:
  - Name: Your name
  - Associated Principal: The principal of the identity used when deploying the canister for the first time, which we call the `owner` of the canister.

> You can decide to hardcode the initial setup or create an external scripts and additional function that will be executed by the `owner` of the canister upon deployment. This is up to you.

8. **Social information** (Optional but recommended if you wish to see your project featured on the Motoko Bootcamp website)

- The DAO exposes public information about it's name, logo, manifesto and social networks. This information is compiled and accessible through the `getStats` function.

```motoko
public type Stats = {
  name : Text; // The name of the DAO;
  logo: Blob; // The logo of the DAO - encoded as a PNG
  picture : Blob; // A picture reprenting the DAO - encoded as a PNG
  numberOfMembers : Nat; // The number of members in the DAO
  manifesto : Text; // The manifesto of the DAO
  socialLinkDAO: Text; // An URL to the DAO's social media page (e.g. Twitter/ OpenChat / Discord / Telegram / DAO's website)
  socialLinkBuilder: Text; // An URL to the DAO's creator social media page (e.g. Twitter/ OpenChat / Personal Blog)
};
```

> The `logo` and `picture` fields are required to be encoded as PNG. The logo should be a square image of 100x100 pixels. The picture should be a 16:9 image of 1920x1080 pixels.

## Token faucet 💰

You are required to use the **Motoko Bootcamp Token**. This a free and educational token faucet. You can mint as much tokens as you need. This token has no real economical value and is only used for educational purposes.

The canister ID of the token faucet canister is: `dg2ce-tqaaa-aaaah-abz6q-cai`. <br/>

You can access to the interface of the token faucet [here](https://dashboard.internetcomputer.org/canister/dg2ce-tqaaa-aaaah-abz6q-cai).

## Types ⚙️

All the necessary types are defined in the [types.mo](./src/types.mo) file.

## Interface 📺

The interface of the DAO should be similar to the following:

```motoko
actor {
    getName : shared query () -> async Text;
    getManifesto : shared query () -> async Text;
    registerMember : shared (name : Text) -> async Result<(),Text>;
    getMember : shared query (p : Principal) -> async Result<Member,Text>;
    getStats : shared query () -> async Stats;
    graduate : shared (student : Principal) -> async Result<(),Text>;
    createProposal : shared (content : ProposalContent) -> async Result<ProposalId,Text>;
    getProposal : shared query (id : ProposalId) -> async Result<Proposal,Text>;
    getAllProposals : shared query () -> async [Proposal];
    voteProposal : shared (proposalId : ProposalId, vote : Vote) -> async Result<(),Text>;
    http_request : shared query (request : HttpRequest) -> async HttpResponse;
}
```

## How to submit your project 📬

Head over to the [Motoko Bootcamp Dashboard](https://www.motokobootcamp.com/), section **Submit**, **Graduation** and input your canister ID.

## Benefits of Graduation 🎓

Your Motoko Bootcamp diploma will grant you the following lifetime benefits:

- Access to a dedicated Motoko Bootcamp Graduate Channel on **OpenChat**.
- Access to a dedicated Motoko Bootcamp Portal on **DSCVR**.
- Access to the **Motoko Bootcamp Manifesto**.
- Possible participation in future **Bootcamps**.
- Additional benefits to be announced.

> **The Motoko Bootcamp Diploma and the associated on-chain infrastructure are still under development. We will keep you updated on the progress.**
