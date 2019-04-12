import gql from 'graphql-tag';

export const GET_ORGANIZATIONS = gql`
    query {
        organization(id: 4) {
            id
            name
        }
    }
`;
