import gql from 'graphql-tag';

export const GET_STEPS_COMPLETED = gql`
    query {
        apolloClient @client {
            stepsCompleted {
                data {
                    x
                    y
                }
            }
        }
    }
`;
