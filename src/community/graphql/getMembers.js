import gql from 'graphql-tag';

export const GET_MEMBERS = gql`
    query {
        apolloClient @client {
            members {
                data {
                    stage
                    members
                    stepsAdded
                    stepsCompleted
                }
            }
        }
    }
`;
