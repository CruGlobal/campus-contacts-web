import gql from 'graphql-tag';

const INTERACTIONS_TOTAL_REPORT = gql`
    query impactReport($communityId: ID!) {
        impactReport(communityId: $communityId) {
            interactionsCount
            interactionsReceiversCount
        }
    }
`;

const INTERACTIONS_TOTAL_COMPLETED_REPORT = gql`
    query communityStagesReport(
        $period: String!
        $communityIds: [ID!]
        $endDate: ISO8601DateTime!
    ) {
        communitiesReport(
            period: $period
            communityIds: $communityIds
            endDate: $endDate
        ) {
            interactions {
                interactionCount
                interactionType {
                    name
                }
            }
        }
    }
`;

const INTERACTIONS_COMPLETED_REPORT = gql`
    query communityDayReport(
        $period: String!
        $communityIds: [ID!]
        $endDate: ISO8601DateTime!
    ) {
        communitiesReport(
            period: $period
            communityIds: $communityIds
            endDate: $endDate
        ) {
            daysReport {
                date
                interactions
                interactionResults {
                    count
                    interactionType {
                        name
                    }
                }
            }
        }
    }
`;

export {
    INTERACTIONS_TOTAL_REPORT,
    INTERACTIONS_TOTAL_COMPLETED_REPORT,
    INTERACTIONS_COMPLETED_REPORT,
};
