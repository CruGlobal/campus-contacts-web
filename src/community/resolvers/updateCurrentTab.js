import gql from 'graphql-tag';

export default (_, { name }, { cache }) => {
    const query = gql`
        query GetTabName {
            apolloClient @client {
                currentTab
            }
        }
    `;

    const previousState = cache.readQuery({ query });

    const data = {
        apolloClient: {
            ...previousState.apolloClient,
            currentTab: name,
        },
    };

    cache.writeQuery({
        query,
        data,
    });

    return null;
};
