import { useQuery } from 'react-apollo-hooks';
import React from 'react';
import { useTranslation } from 'react-i18next';
import styled from '@emotion/styled';

import BarChart from '../BarChart';
import NullState from '../NullState';

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
    nullContent: string;
}
const StepsChart = ({
    query,
    mapData,
    label,
    index,
    variables,
    nullContent,
}: Props) => {
    const { data, loading } = useQuery(query, { variables });
    const { t } = useTranslation('insights');

    const isNull = (data: any) => {
        return data.community.report.stagesReport.filter((stage: any) => {
            return (
                stage.othersStepsAddedCount > 0 ||
                stage.contactCount > 0 ||
                (stage.personalStepsAddedCount > 0 || stage.memberCount > 0)
            );
        });
    };

    if (loading) {
        return <Wrapper>{t('loading')}</Wrapper>;
    }

    if (isNull(data).length === 0) {
        return <NullState content={nullContent} />;
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
