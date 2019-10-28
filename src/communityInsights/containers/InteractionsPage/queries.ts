import gql from 'graphql-tag';

const INTERACTIONS_TOTAL_REPORT = gql`
    query impactReportInteractionsCount($id: ID!) {
        community(id: $id) {
            impactReport {
                interactionsCount
                interactionsReceiversCount
            }
        }
    }
`;

const INTERACTIONS_TOTAL_COMPLETED_REPORT = gql`
    query communityReportInteractions(
        $period: String!
        $id: ID!
        $endDate: ISO8601DateTime!
    ) {
        community(id: $id) {
            report(period: $period, endDate: $endDate) {
                interactions {
                    nodes {
                        interactionCount
                        interactionType {
                            name
                        }
                    }
                }
            }
        }
    }
`;

const INTERACTIONS_COMPLETED_REPORT = gql`
    query communityReportDaysInteractions(
        $period: String!
        $id: ID!
        $endDate: ISO8601DateTime!
    ) {
        community(id: $id) {
            report(period: $period, endDate: $endDate) {
                daysReport {
                    nodes {
                        date
                        interactionsCount
                        interactionResults {
                            nodes {
                                count
                                interactionType {
                                    name
                                }
                            }
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
