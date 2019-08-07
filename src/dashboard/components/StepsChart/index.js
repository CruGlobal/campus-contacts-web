import { useQuery } from 'react-apollo-hooks';
import React from 'react';
import { useTranslation } from 'react-i18next';
import styled from '@emotion/styled';

import BarChart from '../BarChart';

const Wrapper = styled.div`
    height: 400px;
    position: relative;
`;

const StepsChart = ({ query, mapData, label, index, variables }) => {
    const { data, loading } = useQuery(query, { variables });
    const { t } = useTranslation('insights');

    if (loading) {
        return <Wrapper>{t('loading')}</Wrapper>;
    }

    return (
        <Wrapper>
            <BarChart data={mapData(data)} keys={[label]} indexBy={index} />
        </Wrapper>
    );
};

export default StepsChart;
