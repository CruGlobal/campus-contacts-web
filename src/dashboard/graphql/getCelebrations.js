import gql from 'graphql-tag';

export const GET_CELEBRATION_STEPS = gql`
    query {
        apolloClient @client {
            celebrations {
                data {
                    message
                    user
                    key
                }
            }
        }
    }
`;
