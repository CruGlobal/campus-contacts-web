import gql from 'graphql-tag';

export const GET_MEMBERS = gql`
    query {
        apolloClient @client {
            members {
                members_1W {
                    data {
                        stage
                        members
                        stepsAdded
                        stepsCompleted
                    }
                }
                members_default {
                    data {
                        stage
                        members
                        stepsAdded
                        stepsCompleted
                    }
                }
            }
        }
    }
`;
