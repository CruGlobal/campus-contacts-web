import gql from 'graphql-tag';

const GET_IMPACT_CHALLENGES = gql`
    query impactReport($id: ID!) {
        community(id: $id) {
            impactReport {
                stepsCount
            }
        }
    }
`;

const GET_CHALLENGES = gql`
    query globalCommunityChallenges(
        $id: ID!
        $first: Int
        $after: String
        $sortBy: [CommunityChallengesSortEnum!]
    ) {
        community(id: $id) {
            communityChallenges(first: $first, after: $after, sortBy: $sortBy) {
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
