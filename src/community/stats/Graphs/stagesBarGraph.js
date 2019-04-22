// LIBRARIES
import React from 'react';
import { ResponsiveBar } from '@nivo/bar';
import { useQuery } from 'react-apollo-hooks';
import PropTypes from 'prop-types';
// QUERIES
import { GET_CURRENT_FILTER, GET_MEMBERS } from '../../graphql';

const StagesBarGraph = () => {
    const {
        data: {
            apolloClient: {
                currentFilter: { key },
            },
        },
    } = useQuery(GET_CURRENT_FILTER);

    const filterQuery = key;

    const {
        data: {
            apolloClient: { members },
        },
        error,
        loading,
    } = useQuery(GET_MEMBERS, { variables: { filterQuery } });

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message}</div>;
    }

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
            minValue={'auto'}
            maxValue={'auto'}
            padding={0.4}
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
                    legendOffsetY: 60,
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
                    legendOffsetY: 125,
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
                    legendOffsetY: 125,
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
                    legendOffsetY: 60,
                    legendOffsetX: 3,
                },
            ]}
            axisLeft={null}
            enableGridY={true}
            gridYValues={[middle, max]}
            enableLabel={false}
            animate={true}
            motionStiffness={90}
            motionDamping={15}
        />
    );
};

StagesBarGraph.propTypes = {
    members: PropTypes.object,
};

export default StagesBarGraph;
