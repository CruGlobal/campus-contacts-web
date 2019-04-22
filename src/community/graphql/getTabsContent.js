import gql from 'graphql-tag';

export const GET_TAB_CONTENT = gql`
    query {
        apolloClient @client {
            tabsContent {
                data {
                    title
                    key
                    stats
                }
            }
        }
    }
`;
