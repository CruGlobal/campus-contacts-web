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

const GET_CHALLENGES = gql`
    query globalCommunityChallenges($id: ID!, $first: Int, $after: String) {
        community(id: $id) {
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

export { GET_CHALLENGES, GET_IMPACT_CHALLENGES };
