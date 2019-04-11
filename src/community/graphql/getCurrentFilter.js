import gql from 'graphql-tag';

export const GET_CURRENT_FILTER = gql`
    query {
        apolloClient @client {
            currentFilter {
                __typename
                key
                startDate
                endDate
            }
        }
    }
`;
