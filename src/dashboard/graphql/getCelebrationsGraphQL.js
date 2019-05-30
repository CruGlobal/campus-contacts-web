import gql from 'graphql-tag';

export const GET_CELEBRATIONS_GRAPHQL = gql`
    query organization($id: ID!) {
        organization(id: $id) {
            id
            name
            organizationCelebrationItems(last: 4) {
                nodes {
                    id
                    objectType
                    adjectiveAttributeValue
                    subjectPerson {
                        fullName
                        firstName
                    }
                }
                edges {
                    cursor
                }
                pageInfo {
                    startCursor
                    endCursor
                    hasPreviousPage
                    hasNextPage
                }
            }
        }
    }
`;
