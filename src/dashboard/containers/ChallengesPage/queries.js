import gql from 'graphql-tag';

const GET_IMPACT_CHALLENGES = gql`
    query communityReport {
        communityReport {
            impactReport {
                interactionsCount
                interactionsReceiversCount
                challengesCount
            }
        }
    }
`;

const GET_GLOBAL_CHALLENGES = gql`
    query globalCommunityChallenges($first: Int, $after: String) {
        globalCommunityChallenges(first: $first, after: $after) {
            nodes {
                id
                title
                acceptedCount
                completedCount
                createdAt
                endDate
            }
            pageInfo {
                hasNextPage
                startCursor
                endCursor
                hasPreviousPage
            }
        }
    }
`;

const GET_CHALLENGES = gql`
    query organization($id: ID!, $first: Int, $after: String) {
        organization(id: $id) {
            communityChallenges(first: $first, after: $after) {
                nodes {
                    id
                    title
                    acceptedCount
                    completedCount
                    createdAt
                    endDate
                }
                pageInfo {
                    hasNextPage
                    startCursor
                    endCursor
                    hasPreviousPage
                }
            }
        }
    }
`;

export { GET_CHALLENGES, GET_GLOBAL_CHALLENGES, GET_IMPACT_CHALLENGES };
