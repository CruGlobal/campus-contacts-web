import React from 'react';
import PropTypes from 'prop-types';
import { ResponsiveBar } from '@nivo/bar';
import { withTheme } from 'emotion-theming';
import { line } from 'd3-shape';

const BarChart = props => {
    const { theme, data, keys, indexBy, average, tooltip } = props;

    const AverageLine = ({ bars, xScale, yScale }) => {
        if (!average) {
            return null;
        }

        const lineGenerator = line()
            .x(d => {
                const val = xScale(d.data.index) + 2 * d.width + 50;
                if (!val) {
                    return 0;
                }
                return val;
            })
            .y(d => yScale(average));

        return (
            <path
                d={lineGenerator(bars)}
                fill="none"
                strokeDasharray="10, 5"
                strokeWidth="2"
                stroke="#B2ECF7"
            />
        );
    };

    return (
        <ResponsiveBar
            data={data}
            keys={keys}
            indexBy={indexBy}
            theme={theme.graph}
            layers={[AverageLine, 'grid', 'axes', 'bars', 'markers', 'legends']}
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
            tooltip={tooltip}
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
