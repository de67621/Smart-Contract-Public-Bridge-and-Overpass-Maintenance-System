# Smart Contract Public Bridge and Overpass Maintenance System

## Overview

This system provides a comprehensive smart contract solution for managing public bridge and overpass maintenance operations. The system consists of five specialized contracts that handle different aspects of bridge maintenance without cross-contract dependencies.

## System Architecture

### Core Contracts

1. **Bridge Inspection Scheduling Contract** (`bridge-inspection.clar`)
    - Coordinates regular structural inspections
    - Manages inspection schedules and assignments
    - Tracks inspection results and compliance

2. **Bridge Cleaning Coordination Contract** (`bridge-cleaning.clar`)
    - Manages removal of graffiti, debris, and vegetation
    - Schedules cleaning operations
    - Tracks cleaning completion and quality

3. **Bridge Lighting Maintenance Contract** (`bridge-lighting.clar`)
    - Maintains lighting systems for safety and visibility
    - Manages bulb replacements and electrical repairs
    - Monitors lighting functionality

4. **Bridge Joint and Expansion Repair Contract** (`bridge-joint-repair.clar`)
    - Manages maintenance of bridge expansion joints and seals
    - Schedules preventive maintenance
    - Tracks repair history and costs

5. **Bridge Load Limit Enforcement Contract** (`bridge-load-limit.clar`)
    - Monitors and enforces weight restrictions on aging bridges
    - Manages load limit updates
    - Tracks violations and enforcement actions

## Key Features

- **Independent Operation**: Each contract operates independently without cross-contract calls
- **Role-Based Access**: Different roles for administrators, inspectors, and maintenance crews
- **Comprehensive Tracking**: Full audit trail for all maintenance activities
- **Cost Management**: Budget tracking and cost analysis for each maintenance type
- **Safety Compliance**: Ensures all safety protocols are followed
- **Emergency Response**: Priority handling for urgent maintenance needs

## Data Structures

Each contract uses optimized data structures:
- **Maps**: For storing bridge records, maintenance schedules, and personnel assignments
- **Variables**: For system configuration and counters
- **Constants**: For error codes and system limits

## Error Handling

Comprehensive error handling with specific error codes:
- Input validation errors (u100-u199)
- Authorization errors (u200-u299)
- Business logic errors (u300-u399)
- System errors (u400-u499)

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js for running tests
- Basic understanding of Clarity smart contracts

### Installation

1. Clone the repository
2. Install dependencies: `npm install`
3. Run tests: `npm test`
4. Deploy contracts: `clarinet deploy`

### Usage

Each contract provides public functions for:
- Creating and managing maintenance records
- Scheduling operations
- Updating status and completion
- Generating reports
- Managing personnel and resources

## Testing

The system includes comprehensive tests using Vitest:
- Unit tests for each contract function
- Integration tests for complete workflows
- Edge case testing for error conditions
- Performance tests for large datasets

## Security Considerations

- Role-based access control
- Input validation on all public functions
- Protection against unauthorized modifications
- Audit trails for all operations

## Maintenance and Updates

- Regular contract audits recommended
- Version control for contract updates
- Backup procedures for critical data
- Performance monitoring and optimization

## Support

For technical support or questions about the bridge maintenance system, please refer to the documentation or contact the development team.
