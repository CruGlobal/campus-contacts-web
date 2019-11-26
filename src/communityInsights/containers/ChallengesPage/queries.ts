import gql from 'graphql-tag';

const GET_IMPACT_CHALLENGES = gql`
    query impactReportStepsCount($id: ID!) {
        community(id: $id) {
            impactReport {
                stepsCount
            }
        }
    }
`;

const GET_CHALLENGES = gql`
    query communityChallenges(
        $id: ID!
        $first: Int
        $last: Int
        $after: String
        $before: String
        $sortBy: [CommunityChallengesSortEnum!]
    ) {
        community(id: $id) {
            communityChallenges(
                first: $first
                last: $last
                after: $after
                before: $before
                sortBy: $sortBy
            ) {
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
