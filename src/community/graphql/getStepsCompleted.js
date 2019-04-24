import gql from 'graphql-tag';

export const GET_STEPS_COMPLETED = gql`
    query {
        apolloClient @client {
            stepsCompleted_default {
                data {
                    x
                    y
                }
            }
            stepsCompleted_1W {
                data {
                    x
                    y
                }
            }
        }
    }
`;
