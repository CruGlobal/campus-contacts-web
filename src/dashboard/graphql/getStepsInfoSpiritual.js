import gql from 'graphql-tag';

export const GET_STEPSINFO_SPIRITUAL = gql`
    query {
        apolloClient @client {
            stepsInfoSpiritual {
                userStats
            }
        }
    }
`;
