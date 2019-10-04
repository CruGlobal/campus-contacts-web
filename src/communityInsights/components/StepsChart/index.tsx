import { useQuery } from 'react-apollo-hooks';
import React from 'react';
import styled from '@emotion/styled';

import BarChart from '../BarChart';
import NullState from '../NullState';

const Wrapper = styled.div<isNull>`
    height: ${(props: isNull) => (props.isNull ? 'auto' : '400px')};
    position: relative;
`;

interface isNull {
    isNull: boolean;
}
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

    const checkForNullContent = (data: any) => {
        const nullCheck = data.community.report.stagesReport.filter(
            (stages: any) => {
                return (
                    stages.memberCount !== 0 &&
                    stages.personalStepsAddedCount !== 0 &&
                    stages.othersStepsAddedCount !== 0 &&
                    stages.contactCount !== 0
                );
            },
        );

        return nullCheck.length === 0;
    };

    if (loading) {
        return <NullState content={nullContent} />;
    }

    return (
        <Wrapper isNull={checkForNullContent(data)}>
            <BarChart
                nullContent={nullContent}
                nullCheck={checkForNullContent(data)}
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
