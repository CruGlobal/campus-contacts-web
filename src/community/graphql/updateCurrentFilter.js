import gql from 'graphql-tag';

export const UPDATE_CURRENT_FILTER = gql`
    mutation updateCurrentFilter($filter: String!) {
        updateCurrentFilter(filter: $filter) @client {
            currentFilter
        }
    }
`;
