import gql from 'graphql-tag';

export default (_, { filter }, { cache }) => {
    const query = gql`
        query {
            apolloClient @client {
                currentFilter {
                    key
                    startDate
                    endDate
                }
            }
        }
    `;

    const previousState = cache.readQuery({ query });

    filter.__typename = 'currentFilter';

    const data = {
        apolloClient: {
            ...previousState.apolloClient,
            currentFilter: filter,
        },
    };

    cache.writeQuery({
        query,
        data,
    });

    return null;
};
