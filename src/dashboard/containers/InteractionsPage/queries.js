import gql from 'graphql-tag';

const INTERACTIONS_TOTAL_REPORT = gql`
    query impactReport($id: ID!) {
        community(id: $id) {
            impactReport {
                interactionsCount
                interactionsReceiversCount
            }
        }
    }
`;

const INTERACTIONS_TOTAL_COMPLETED_REPORT = gql`
    query communityStagesReport(
        $period: String!
        $id: ID!
        $endDate: ISO8601DateTime!
    ) {
        community(id: $id) {
            report(period: $period, endDate: $endDate) {
                interactions {
                    interactionCount
                    interactionType {
                        name
                    }
                }
            }
        }
    }
`;

const INTERACTIONS_COMPLETED_REPORT = gql`
    query communityDayReport(
        $period: String!
        $id: ID!
        $endDate: ISO8601DateTime!
    ) {
        community(id: $id) {
            report(period: $period, endDate: $endDate) {
                daysReport {
                    date
                    interactionsCount
                    interactionResults {
                        count
                        interactionType {
                            name
                        }
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
