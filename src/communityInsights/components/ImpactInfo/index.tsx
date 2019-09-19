import { useTranslation } from 'react-i18next';
import { useQuery } from 'react-apollo-hooks';
import React from 'react';

import Header from '../Header';
import NullState from '../NullState';

interface Props {
    query: any;
    text: (data: any) => string;
    variables: any;
}

const ImpactInfo = ({ query, text, variables }: Props) => {
    const { data, loading } = useQuery(query, { variables });
    const { t } = useTranslation('insights');

    if (loading) {
        return (
            <Header>
                <NullState impactInfo={true}></NullState>
            </Header>
        );
    }
    return <Header>{text(data)} </Header>;
};

export default ImpactInfo;
