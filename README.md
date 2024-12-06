# FundStreaming Smart Contract

## Overview
FundStreaming is a Solidity-based smart contract that facilitates the creation and management of crowdfunding campaigns. It allows donors to contribute funds and enables campaign owners to withdraw funds based on specific conditions. The contract ensures transparency and security by leveraging Ethereum’s blockchain technology.

---

## Features
1. **Campaign Creation**:
   - Create campaigns with a title, description, target amount, start and end time, and an optional image.
2. **Donations**:
   - Donors can contribute ETH to active campaigns.
3. **Fund Streaming**:
   - Campaign owners can withdraw funds gradually, based on the time elapsed since the campaign started.
4. **Milestone Management**:
   - Campaign owners can set milestone statuses.
5. **Refunds**:
   - Donors can withdraw their contributions if milestones are unmet and the campaign has ended.
6. **Data Retrieval**:
   - Fetch campaign details, including donors and their contributions.

---

## Prerequisites
- **Solidity Version**: `^0.8.9`
- Ethereum-compatible blockchain (e.g., Ethereum, Polygon, etc.)
- Development environment: Remix, Hardhat, or Truffle.

---

## Contract Structure
### 1. **Campaign**
The `Campaign` struct represents a single campaign and contains the following fields:
```solidity
struct Campaign {
    address owner;
    string title;
    string description;
    uint256 target;
    uint256 startTime;
    uint256 endTime;
    uint256 totalFunds;
    uint256 amountStreamed;
    uint256 lastStreamedTimestamp;
    string image;
    address[] donators;
    uint256[] donations;
}
```

### 2. **Mappings**
- `campaigns`: Maps a campaign ID to its `Campaign` struct.
- `milestoneMet`: Tracks whether a campaign's milestones have been met.

### 3. **State Variables**
- `numberOfCampaigns`: Tracks the total number of campaigns created.

---

## Functions

### 1. **createCampaign**
```solidity
function createCampaign(
    address _owner,
    string memory _title,
    string memory _description,
    uint256 _target,
    uint256 _startTime,
    uint256 _endTime,
    string memory _image
) public returns (uint256);
```
Creates a new campaign. The `_endTime` must be greater than `_startTime`, and `_startTime` must be in the future.

### 2. **donateToCampaign**
```solidity
function donateToCampaign(uint256 _id) public payable;
```
Allows users to donate ETH to a campaign before its end time.

### 3. **withdrawFunds**
```solidity
function withdrawFunds(uint256 _id) public;
```
Allows campaign owners to withdraw streamed funds proportional to the time elapsed since the campaign started.

### 4. **withdrawDonations**
```solidity
function withdrawDonations(uint256 _id) public;
```
Allows donors to withdraw their contributions if the campaign has ended and milestones are unmet.

### 5. **setMilestoneStatus**
```solidity
function setMilestoneStatus(uint256 _id, bool _status) public onlyOwner(_id);
```
Sets the milestone status for a campaign. Only callable by the campaign owner.

### 6. **getDonators**
```solidity
function getDonators(uint256 _id) public view returns (address[] memory, uint256[] memory);
```
Returns the list of donors and their respective contributions for a campaign.

### 7. **getCampaigns**
```solidity
function getCampaigns() public view returns (Campaign[] memory);
```
Returns all campaigns created.

---

## Deployment
1. Open [Remix](https://remix.ethereum.org/).
2. Copy and paste the contract into a new file.
3. Compile the contract using Solidity version `^0.8.9`.
4. Deploy the contract to an Ethereum-compatible blockchain.

---

## Usage

### 1. **Creating a Campaign**
Call the `createCampaign` function with the following parameters:
- `address _owner`: The campaign owner's address.
- `string _title`: Title of the campaign.
- `string _description`: Description of the campaign.
- `uint256 _target`: Target amount in wei.
- `uint256 _startTime`: Campaign start time (UNIX timestamp).
- `uint256 _endTime`: Campaign end time (UNIX timestamp).
- `string _image`: URL or description of the campaign image.

### 2. **Donating to a Campaign**
Call the `donateToCampaign` function with the campaign ID and send ETH as `msg.value`.

### 3. **Withdrawing Funds**
Call the `withdrawFunds` function with the campaign ID to withdraw streamed funds.

### 4. **Getting Campaign Details**
Call `getCampaigns` to fetch all campaign details or `getDonators` for specific donor details of a campaign.

---

## Example Interactions

### Using Remix
1. Deploy the contract.
2. Create a campaign:
   ```solidity
   createCampaign(
       "0xYourAddressHere",
       "Save the Forests",
       "A campaign to raise funds for reforestation.",
       1000000000000000000, // 1 ETH in Wei
       1729305600, // Example start time
       1731907200, // Example end time
       "image_url"
   );
   ```
3. Donate to the campaign:
   ```solidity
   donateToCampaign(0, { value: 500000000000000000 }); // 0.5 ETH
   ```
4. Withdraw funds:
   ```solidity
   withdrawFunds(0);
   ```

---

## License
This project is licensed under the MIT License. See the LICENSE file for details.

