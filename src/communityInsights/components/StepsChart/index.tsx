import { useQuery } from 'react-apollo-hooks';
import React from 'react';
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
}
const StepsChart = ({ query, mapData, label, index, variables }: Props) => {
    const { data, loading } = useQuery(query, { variables });

    if (loading) {
        return <NullState width={400} />;
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
