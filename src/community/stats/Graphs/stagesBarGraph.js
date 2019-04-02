import React from 'react';
import { ResponsiveBar } from '@nivo/bar';
import { useQuery } from 'react-apollo-hooks';
import { GET_MEMBERS } from '../../graphql';

const StagesBarGraph = () => {
    const {
        data: {
            apolloClient: { members },
        },
        error,
        loading,
    } = useQuery(GET_MEMBERS);

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message}</div>;
    }

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
