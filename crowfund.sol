// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract FundStreaming {
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

    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => bool) public milestoneMet;

    uint256 public numberOfCampaigns = 0;

    modifier onlyOwner(uint256 _id) {
        require(msg.sender == campaigns[_id].owner, "Only the campaign owner can perform this action.");
        _;
    }

    function createCampaign(
        address _owner,
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _startTime,
        uint256 _endTime,
        string memory _image
    ) public returns (uint256) {
        require(_endTime > _startTime, "End time must be greater than start time.");
        require(_startTime > block.timestamp, "Start time must be in the future.");

        Campaign storage campaign = campaigns[numberOfCampaigns];

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.startTime = _startTime;
        campaign.endTime = _endTime;
        campaign.totalFunds = 0;
        campaign.amountStreamed = 0;
        campaign.lastStreamedTimestamp = _startTime;
        campaign.image = _image;

        numberOfCampaigns++;
        return numberOfCampaigns - 1;
    }

    function donateToCampaign(uint256 _id) public payable {
        require(block.timestamp < campaigns[_id].endTime, "Cannot donate after the campaign end time.");

        uint256 amount = msg.value;
        Campaign storage campaign = campaigns[_id];

        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);
        campaign.totalFunds += amount;
    }

    function withdrawFunds(uint256 _id) public {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.startTime, "Streaming has not started yet.");
        require(msg.sender == campaign.owner, "Only the campaign owner can withdraw funds.");

        uint256 timeElapsed = block.timestamp - campaign.lastStreamedTimestamp;
        uint256 streamableAmount = (campaign.totalFunds * timeElapsed) / (campaign.endTime - campaign.startTime);

        uint256 amountToWithdraw = streamableAmount - campaign.amountStreamed;

        require(amountToWithdraw > 0, "No funds available for withdrawal yet.");

        campaign.amountStreamed += amountToWithdraw;
        campaign.lastStreamedTimestamp = block.timestamp;

        (bool sent, ) = payable(campaign.owner).call{value: amountToWithdraw}("");
        require(sent, "Failed to send funds.");
    }

    function withdrawDonations(uint256 _id) public {
        Campaign storage campaign = campaigns[_id];
        require(!milestoneMet[_id], "Milestones have been met; donations cannot be withdrawn.");
        require(block.timestamp > campaign.endTime, "Campaign has not ended yet.");

        uint256 totalDonation;
        for (uint256 i = 0; i < campaign.donators.length; i++) {
            if (campaign.donators[i] == msg.sender) {
                totalDonation += campaign.donations[i];
            }
        }

        require(totalDonation > 0, "You have no donations to withdraw.");

        (bool sent, ) = payable(msg.sender).call{value: totalDonation}("");
        require(sent, "Failed to send donation refund.");
    }

    function setMilestoneStatus(uint256 _id, bool _status) public onlyOwner(_id) {
        milestoneMet[_id] = _status;
    }

    function getDonators(uint256 _id) public view returns (address[] memory, uint256[] memory) {
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for (uint256 i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];
            allCampaigns[i] = item;
        }

        return allCampaigns;
    }
}
