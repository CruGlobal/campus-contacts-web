import gql from 'graphql-tag';

export const GET_IMPACT_REPORT = gql`
    query organizationReport($id: ID!) {
        impactReport(organizationId: $id) {
            pathwayMovedCount
            stepsCount
            receiversCount
            stepOwnersCount
        }
    }
`;
