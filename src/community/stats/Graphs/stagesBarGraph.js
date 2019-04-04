import React from 'react';
import { ResponsiveBar } from '@nivo/bar';
import { useQuery } from 'react-apollo-hooks';
import { GET_CURRENT_FILTER, GET_MEMBERS } from '../../graphql';

const StagesBarGraph = () => {
    const {
        data: {
            apolloClient: { filter },
        },
    } = useQuery(GET_CURRENT_FILTER);
    const {
        data: {
            apolloClient: { members },
        },
        error,
        loading,
    } = useQuery(GET_MEMBERS, { variables: { filter } });

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message}</div>;
    }

    // We need to extact the members data and then calculate the largest number and set that to the max and then divide that number by two for the side markers
    let max = 50;
    let middle = max / 2;

    return (
        <ResponsiveBar
            data={members.data}
            keys={['stepsAdded', 'stepsCompleted']}
            indexBy="stage"
            margin={{
                top: 30,
                right: 0,
                bottom: 50,
                left: 0,
            }}
            padding={0.2}
            innerPadding={3}
            colors={['#3CC8E6', '#007398']}
            colorBy="id"
            axisTop={null}
            groupMode={'grouped'}
            axisRight={null}
            axisBottom={{
                tickSize: 0,
                tickPadding: 20,
            }}
            markers={[
                {
                    axis: 'y',
                    value: 0,
                    lineStyle: { strokeOpacity: 0 },
                    textStyle: { fill: 'lightgrey' },
                    legend: `${middle}`,
                    legendPosition: 'top-left',
                    legendOrientation: 'horizontal',
                    legendOffsetY: 55,
                    legendOffsetX: 3,
                },
                {
                    axis: 'y',
                    value: 0,
                    lineStyle: { stroke: 'lightgrey', strokeOpacity: 0 },
                    textStyle: { fill: 'lightgrey' },
                    legend: `${max}`,
                    legendPosition: 'top-left',
                    legendOrientation: 'horizontal',
                    legendOffsetY: 120,
                    legendOffsetX: 3,
                },
                {
                    axis: 'y',
                    value: 0,
                    lineStyle: { stroke: 'lightgrey', strokeOpacity: 0 },
                    textStyle: { fill: 'lightgrey' },
                    legend: `${max}`,
                    legendPosition: 'top-right',
                    legendOrientation: 'horizontal',
                    legendOffsetY: 120,
                    legendOffsetX: 3,
                },
                {
                    axis: 'y',
                    value: 0,
                    lineStyle: { stroke: 'lightgrey', strokeOpacity: 0 },
                    textStyle: { fill: 'lightgrey' },
                    legend: `${middle}`,
                    legendPosition: 'top-right',
                    legendOrientation: 'horizontal',
                    legendOffsetY: 55,
                    legendOffsetX: 3,
                },
            ]}
            axisLeft={null}
            enableGridY={true}
            gridYValues={[25, 50]}
            enableLabel={false}
            animate={true}
            motionStiffness={90}
            motionDamping={15}
        />
    );
};

StagesBarGraph.propTypes = {};

export default StagesBarGraph;
