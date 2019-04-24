// LIBRARIES
import React from 'react';
import { ResponsiveLine } from '@nivo/line';
import { useQuery } from 'react-apollo-hooks';
import PropTypes from 'prop-types';
// QUERIES
import { GET_CURRENT_FILTER, GET_STEPS_COMPLETED } from '../../graphql';

const StagesLineGraph = () => {
    const { data, loading, error } = useQuery(GET_CURRENT_FILTER);

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message}</div>;
    }

    const {
        apolloClient: {
            currentFilter: { key },
        },
    } = data;

    const switchStepsCompleted = () => {
        switch (key) {
            case '1W': {
                const {
                    data: {
                        apolloClient: { stepsCompleted_1W },
                    },
                } = useQuery(GET_STEPS_COMPLETED);
                return stepsCompleted_1W;
            }
            default: {
                const {
                    data: {
                        apolloClient: { stepsCompleted_default },
                    },
                } = useQuery(GET_STEPS_COMPLETED);
                return stepsCompleted_default;
            }
        }
    };

    const StepsCompleted = switchStepsCompleted();

    return (
        <ResponsiveLine
            data={[
                {
                    id: 'Steps Completed',
                    color: 'hsl(195, 100%, 74%)',
                    data: StepsCompleted.data,
                },
            ]}
            margin={{
                top: 30,
                right: 40,
                bottom: 50,
                left: 40,
            }}
            xScale={{
                type: 'point',
            }}
            yScale={{
                type: 'linear',
                stacked: true,
                min: 'auto',
                max: 'auto',
            }}
            enableGridX={false}
            enableGridY={false}
            axisTop={null}
            axisRight={null}
            axisBottom={{
                orient: 'bottom',
                tickSize: 10,
                tickPadding: 20,
                tickRotation: 0,
            }}
            axisLeft={null}
            dotSize={15}
            dotColor="white"
            dotBorderWidth={2}
            dotBorderColor="#3CC8E6"
            enableDotLabel={true}
            dotLabel="y"
            dotLabelYOffset={-15}
            animate={true}
            motionStiffness={90}
            motionDamping={15}
            colors={'hsl(195, 100%, 74%)'}
        />
    );
};

StagesLineGraph.propTypes = {
    stepsCompleted: PropTypes.object,
};

export default StagesLineGraph;
