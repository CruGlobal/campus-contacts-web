import gql from 'graphql-tag';

const INTERACTIONS_TOTAL_REPORT = gql`
    query communityReport {
        communityReport {
            impactReport {
                interactionsCount
                interactionsReceiversCount
            }
        }
    }
`;

const INTERACTIONS_TOTAL_COMPLETED_REPORT = gql`
    query communityReport {
        communityReport {
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
    query communityReport {
        communityReport {
            dayReport {
                date
                interactionCount
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

export {
    INTERACTIONS_TOTAL_REPORT,
    INTERACTIONS_TOTAL_COMPLETED_REPORT,
    INTERACTIONS_COMPLETED_REPORT,
};
