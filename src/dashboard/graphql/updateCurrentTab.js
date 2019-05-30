import gql from 'graphql-tag';

export const UPDATE_CURRENT_TAB = gql`
    mutation updateCurrentTab($name: String!) {
        updateCurrentTab(name: $name) @client {
            currentTab
        }
    }
`;
