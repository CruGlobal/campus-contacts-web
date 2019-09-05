import { useQuery } from 'react-apollo-hooks';
import React from 'react';
import { useTranslation } from 'react-i18next';
import styled from '@emotion/styled';

import BarChart from '../BarChart';

const Wrapper = styled.div`
    height: 400px;
    position: relative;
`;

interface Props {
    query: any;
    mapData: (data: any) => any;
    variables: any;
    label: string;
    index: string;
}
const StepsChart = ({ query, mapData, label, index, variables }: Props) => {
    const { data, loading } = useQuery(query, { variables });
    const { t } = useTranslation('insights');

    if (loading) {
        return <Wrapper>{t('loading')}</Wrapper>;
    }

    return (
        <Wrapper>
            <BarChart
                data={mapData(data)}
                keys={[label]}
                indexBy={index}
                onFilterChanged={() => {}}
                index={0}
                filterType={'month'}
            />
        </Wrapper>
    );
};

export default StepsChart;
