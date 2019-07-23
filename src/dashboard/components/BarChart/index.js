import React from 'react';
import PropTypes from 'prop-types';
import { ResponsiveBar } from '@nivo/bar';
import { withTheme } from 'emotion-theming';

const BarChart = props => {
    const { theme, data, keys, indexBy } = props;

    return (
        <ResponsiveBar
            data={data}
            keys={keys}
            indexBy={indexBy}
            theme={theme.graph}
            margin={{
                top: 30,
                right: 0,
                bottom: 90,
                left: 30,
            }}
            minValue={'auto'}
            maxValue={'auto'}
            padding={0.4}
            innerPadding={3}
            colors={[theme.colors.highlight, theme.colors.highlightDarker]}
            colorBy="id"
            axisTop={null}
            groupMode={'grouped'}
            axisRight={null}
            axisBottom={{
                tickSize: 0,
                tickPadding: 20,
            }}
            axisLeft={{
                tickSize: 0,
                tickPadding: 5,
                tickRotation: 0,
            }}
            enableGridY={true}
            enableLabel={false}
            animate={true}
            motionStiffness={90}
            motionDamping={15}
        />
    );
};

export default withTheme(BarChart);

BarChart.propTypes = {
    title: PropTypes.string,
    subtitle: PropTypes.string,
    children: PropTypes.element,
};
