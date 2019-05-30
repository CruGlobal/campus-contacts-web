import gql from 'graphql-tag';

export const GET_ORGANIZATIONS = gql`
    query organization($id: ID!) {
        organization(id: $id) {
            id
            name
        }
    }
`;
