// LIBRARIES
import { useQuery } from 'react-apollo-hooks';
// QUERIES
import { GET_TAB_CONTENT } from '../../graphql';

const tabContent = () => {
    const { data, loading, error } = useQuery(GET_TAB_CONTENT);

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message}</div>;
    }

    const {
        apolloClient: { tabsContent },
    } = data;

    const TabContent = tabsContent.data;

    return TabContent;
};

export { tabContent };
