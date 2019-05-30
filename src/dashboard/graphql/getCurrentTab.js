import gql from 'graphql-tag';

export const GET_CURRENT_TAB = gql`
    query {
        apolloClient @client {
            currentTab
        }
    }
`;
