import React from 'react';
import { ResponsiveBar } from '@nivo/bar';
import { useQuery } from 'react-apollo-hooks';
import { GET_CURRENT_FILTER, GET_STEPS_COMPLETED_GRAPHQL } from '../../graphql';

const StagesBarGraph = () => {
    const {
        data: {
            apolloClient: { filter },
        },
    } = useQuery(GET_CURRENT_FILTER);

    const { data, loading, error } = useQuery(GET_STEPS_COMPLETED_GRAPHQL, {
        variables: { filter },
    });

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message} </div>;
    }

    const { organization } = data;

    const orgsList = [];

    // This orgsList setup is not optimal but hopefully will change as
    // Graphql schema is changed and modified.

    orgsList.push(organization.stage_0);
    // We want to index our graph by the stages name, to do that we have to go into
    // pathwayStage.name but the graph doesn't like going into nested objects.
    // To fix this I had to add a name value set equal to that nested value.
    orgsList[0].name = organization.stage_0.pathwayStage.name;
    orgsList.push(organization.stage_1);
    orgsList[1].name = organization.stage_1.pathwayStage.name;
    orgsList.push(organization.stage_2);
    orgsList[2].name = organization.stage_2.pathwayStage.name;
    orgsList.push(organization.stage_3);
    orgsList[3].name = organization.stage_3.pathwayStage.name;
    orgsList.push(organization.stage_4);
    orgsList[4].name = organization.stage_4.pathwayStage.name;
    orgsList.push(organization.stage_5);
    orgsList[5].name = organization.stage_5.pathwayStage.name;

    // We need to extact the members data and then calculate the largest number and set that to the max and then divide that number by two for the side markers
    let max = 18;
    let middle = max / 2;

    return (
        <ResponsiveBar
            data={orgsList}
            keys={['stepsAddedCount', 'stepsCompletedCount']}
            indexBy="name"
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
                    legendOffsetY: 130,
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
                    legendOffsetY: 130,
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

StagesBarGraph.propTypes = {};

export default StagesBarGraph;
