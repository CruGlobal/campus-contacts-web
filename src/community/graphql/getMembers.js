import gql from 'graphql-tag';

const membersData = 'members_default';

export const GET_MEMBERS = gql`
    query {
        apolloClient @client {
            ${membersData} {
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
