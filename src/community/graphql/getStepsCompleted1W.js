import gql from 'graphql-tag';

export const GET_STEPS_COMPLETED_1W = gql`
    query {
        apolloClient @client {
            stepsCompleted_1W {
                data {
                    x
                    y
                }
            }
        }
    }
`;
