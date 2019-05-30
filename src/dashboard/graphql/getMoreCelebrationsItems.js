import gql from 'graphql-tag';

export const GET_MORE_CELEBRATIONS_ITEMS = gql`
    query organization($id: ID!, $before: String, $after: String) {
        organization(id: $id) {
            id
            name
            organizationCelebrationItems(
                last: 4
                before: $before
                after: $after
            ) {
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
