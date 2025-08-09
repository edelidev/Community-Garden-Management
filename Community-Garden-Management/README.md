# Community Garden Management Smart Contract

A decentralized mentorship platform built on the Stacks blockchain that connects gardening mentors and mentees through tokenized incentives and community garden management.

##  Overview

This smart contract facilitates mentorship relationships in community gardening by:
- Creating and managing community garden spaces
- Registering mentors and mentees with specific garden assignments
- Facilitating mentorship sessions with transparent rating systems
- Distributing tokenized rewards based on session completion and ratings
- Implementing SIP-010 fungible token standard for Community Garden Tokens (CGT)

##  Features

### Garden Management
- **Garden Creation**: Contract owners can create new community gardens with defined capacities
- **Member Allocation**: Automatic assignment and tracking of mentors/mentees per garden
- **Capacity Control**: Prevents overcrowding with configurable garden member limits

### Mentor System
- **Registration**: Mentors register with expertise areas and garden assignments
- **Rating System**: Performance-based ratings from 1-10 scale
- **Token Rewards**: Base rewards plus performance bonuses for high-rated sessions
- **Activity Tracking**: Complete session history and earnings tracking

### Mentee System
- **Profile Creation**: Mentees specify experience level and learning goals
- **Garden Assignment**: Join specific community gardens for localized mentorship
- **Progress Tracking**: Monitor completed sessions and learning journey
- **Rating Participation**: Provide feedback on mentor performance

### Tokenized Incentives
- **Community Garden Token (CGT)**: ERC-20 compatible fungible token
- **Welcome Rewards**: New members receive initial token allocation
- **Session Rewards**: Mentors earn tokens based on session duration and ratings
- **Performance Bonuses**: Additional rewards for highly-rated mentorship

##  Contract Functions

### Public Functions

#### Garden Management
- `create-garden(name, location, capacity)` - Create new community garden (owner only)

#### User Registration
- `register-mentor(name, expertise, garden-id)` - Register as a mentor
- `register-mentee(name, experience-level, goals, garden-id)` - Register as a mentee

#### Session Management
- `create-session(mentor, mentee, garden-id, topic, duration-hours)` - Schedule mentorship session
- `complete-session(session-id, mentor-rating, mentee-rating)` - Complete and rate session

#### Token Operations
- `transfer(amount, from, to, memo)` - Transfer CGT tokens between users

### Read-Only Functions
- `get-mentor(mentor-id)` - Retrieve mentor profile and stats
- `get-mentee(mentee-id)` - Retrieve mentee profile and progress
- `get-session(session-id)` - Get session details and ratings
- `get-garden(garden-id)` - View garden information and statistics
- `get-balance(principal)` - Check CGT token balance
- `get-total-supply()` - Get total CGT token supply

##  Token Economics

### Token Distribution
- **Mentors**: 1,000,000 CGT welcome bonus upon registration
- **Mentees**: 500,000 CGT welcome bonus upon registration
- **Session Rewards**: Base 100,000 CGT per hour + performance bonuses

### Reward Structure
- **Base Rate**: 100,000 CGT per session hour
- **Performance Bonus**: Additional 50,000 CGT for ratings ≥ 8/10
- **Quality Incentive**: Mentor ratings dynamically updated based on feedback

##  Technical Specifications

### Token Standard
- **Standard**: SIP-010 (Stacks Fungible Token)
- **Name**: Community Garden Token
- **Symbol**: CGT
- **Decimals**: 6

### Data Structures
- **Mentors**: Profile, expertise, ratings, earnings, garden assignment
- **Mentees**: Profile, goals, progress, current mentor, garden assignment
- **Sessions**: Participants, topic, duration, ratings, rewards, timestamp
- **Gardens**: Name, location, capacity, member counts, session statistics

### Security Features
- **Access Control**: Owner-only functions for garden creation
- **Authorization Checks**: Session participants only can complete sessions
- **Validation**: Input sanitization and business logic enforcement
- **Error Handling**: Comprehensive error codes and messages

##  Deployment

### Prerequisites
- Stacks blockchain development environment
- Clarinet for testing and deployment
- STX tokens for contract deployment

### Installation Steps
1. Clone the repository
2. Install Clarinet CLI
3. Run tests with `clarinet test`
4. Deploy with `clarinet deploy`

### Configuration
- Set contract owner address before deployment
- Configure initial garden parameters
- Adjust token economics parameters as needed

##  Testing

Run the test suite:
```bash
clarinet test
```

Key test scenarios:
- Garden creation and capacity management
- Mentor/mentee registration flows
- Session creation and completion
- Token minting and transfer operations
- Rating system validation
- Access control enforcement

##  Usage Examples

### Creating a Community Garden
```clarity
(contract-call? .community-garden create-garden 
  "Downtown Community Garden" 
  "123 Main Street" 
  u50)
```

### Registering as a Mentor
```clarity
(contract-call? .community-garden register-mentor 
  "Alice Green" 
  "Organic vegetables and composting" 
  u1)
```

### Completing a Session
```clarity
(contract-call? .community-garden complete-session 
  u1 
  u9 
  u8)
```

##  Contributing

1. Fork the repository
2. Create a feature branch
3. Write comprehensive tests
4. Follow Clarity coding standards
5. Submit a pull request

##  License

This project is licensed under the MIT License - see the LICENSE file for details.

##  Community

Join our community gardening movement:
- Discord: [Community Garden DAO]
- Twitter: [@CommunityGardenDAO]
- Website: [www.communitygarden.dao]

##  Disclaimers

This smart contract is provided as-is for educational and community purposes. Users should:
- Conduct thorough testing before mainnet deployment
- Review security implications for production use
- Comply with local regulations regarding token distribution
- Consider professional security audit before handling significant value