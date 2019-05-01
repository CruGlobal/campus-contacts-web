import gql from 'graphql-tag';

export const GET_CELEBRATIONS_GRAPHQL = gql`
    query organization($id: ID!) {
        organization(id: $id) {
            id
            name
            organizationCelebrationItems {
                nodes {
                    id
                    objectType
                    adjectiveAttributeValue
                    subjectPerson {
                        fullName
                        firstName
                    }
                }
            }
        }
    }
`;
