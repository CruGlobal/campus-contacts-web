import gql from 'graphql-tag';

export const GET_MEMBERS_1W = gql`
    query {
        apolloClient @client {
            members_1W {
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
