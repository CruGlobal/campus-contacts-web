import gql from 'graphql-tag';

export const GET_STEPSINFO_PERSONAL = gql`
    query {
        apolloClient @client {
            stepsInfoPersonal {
                userStats
                numberStats
                peopleStats
            }
        }
    }
`;
